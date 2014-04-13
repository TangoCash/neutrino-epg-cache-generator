#! /usr/bin/perl -w
use strict;

### CONFIGURATION #############################################################
my $password = "000";
my $user = "TVprg";
my $connect = "DBI:mysql:database=TVprg";

my @default_langs = ("ru", "en");
###############################################################################

use DBI;
use XMLTV::Version '$Id: xmltv-import.pl,v 1.10 2004/04/17 08:56:54 stesie Exp $ ';
use XMLTV qw(best_name);
use Getopt::Long;
use Date::Manip;
use feature 'unicode_strings';
use locale;
use POSIX qw(setlocale locale_h LC_ALL);
setlocale(LC_ALL, "ru_RU.utf8");

sub db_dupscan();
sub bn_wrap($$);


#-- usage information
use XMLTV::Usage <<EOF
$0: import xmltv-data into TVprg.php database
usage: $0 [--help] [--dupscan] [--lang lang] [--force] [FILE...]

	--help		this text
	--dupscan	scan the database for duplicate entries after import
	--lang		prefer specified language (multiple lang-args possible)
	--force		force the import (no timechecking etc.)

EOF
;
#---

#-- read the present command line options
my $opt_help = 0;
my $opt_dupscan = 0;
my $opt_force = 0;
my $langs = [];

GetOptions("help" => \$opt_help, 
	   "dupscan" => \$opt_dupscan, 
	   "lang=s" => \@$langs,
	   "force" => \$opt_force) or usage(0);

usage(1) if($opt_help);
#---

#-- warn when trying to use unsupported stuff
warn "force flag not yet supported!" if($opt_force);
#---

#-- establish database connection now!
my $dbh = DBI->connect($connect,$user,$password) or die "cannot connect to mySQL database";
my ($sth, $upd);
my @row;
#---

#-- if only --dupscan is present, do that and exit ...
if ($opt_dupscan and not @ARGV) { db_dupscan(); exit 0; }
@ARGV = ('-') unless @ARGV;
push @$langs, @default_langs unless(@$langs);
#---

### XMLTV Callback Functions ##################################################

#-- encoding callback
sub encoding_cb($) { shift; }	# don't give a fuck about that one!
#---

#-- credits callback
sub credits_cb($) { shift; }  # don't care for the credits of the grabber (yet)
#---

#-- channels callback
my %chid_map;
sub channel_cb($) {
	# lookup the channel id for this channel, create a new chid-entry if
	# there's no chid available

	my $ch = shift;

  lookup_again:	
	$sth = $dbh->prepare("SELECT id FROM channels WHERE tvuri=?");
	$sth->execute ($ch->{id}) or die "SELECT-Query for channel_cb failed";
	if (@row = $sth->fetchrow_array()) {
		$chid_map{$ch->{id}} = $row[0];
		$sth->finish();
		return;
	}

	$sth->finish();

	#-- no chid available, create one.
	$sth = $dbh->prepare("INSERT INTO channels(id,tvuri,download,friendly_name) VALUES (NULL, ?, 1, ?)");
	my ($chname, $lang) = @{XMLTV::best_name($langs, $ch->{'display-name'})};
	$sth->execute($ch->{id}, $chname) or next;
	$sth->finish();
	goto lookup_again;
}
#---

#--- begintime-conversion "yyyymmddhhmmss" to unixtime (seconds since 1970)
sub convert_begintime($) {
	my $src = shift;

	#print STDERR "in: $src\n";
	#print STDERR "with tz: ", UnixDate(Date_ConvTZ(ParseDate($src), "", "UTC"), "%s"), "\n";
	#print STDERR "without tz: ", UnixDate(ParseDate($src), "%s"), "\n";
	return UnixDate(ParseDate($src), "%s");
}
#---

#-- tvshow callback
sub programme_cb($) {
	my $show = shift;

	$sth = $dbh->prepare ("INSERT INTO programmes(id,begintime,endtime,channel,title,subtitle,text,category) VALUES(NULL,?,?,?,?,?,?,?)");
	my $show_id = $sth->execute(convert_begintime ($show->{'start'}),
					(convert_begintime ($show->{'stop'}),	
				    $chid_map{$show->{channel}},
				    (bn_wrap($show, "title")),
				    (bn_wrap($show, "sub-title")),
				    (bn_wrap($show, "desc")),
				    (bn_wrap($show, "category")))) 
	  or die "cannot insert show into database";

	if(defined($show->{'credits'})) {
		my @jobs = ('director', 'actor', 'writer', 'adapter', 'producer', 'presenter',
			    'commentator', 'guest');
		
		for(my $j = 0; $j < @jobs; $j ++) {
			import_credits($show, $dbh->{'mysql_insertid'}, $jobs[$j], $j);
		}
	}

	$sth->finish();
}
#---

#-- best_name wrapper, returning undef, if field not defined
sub bn_wrap($$) {
	my $show = shift;
	my $field = shift;

	return(undef) unless(defined($show->{$field}));
	return @{XMLTV::best_name($langs, $show->{$field})}[0];
}
#---
	
my $cred_hdl = $dbh->prepare ("INSERT INTO credits(id,showid,name,type) VALUES(NULL,?,?,?)");
sub import_credits($$$$) {
	my $show = shift;
	my $showid = shift;
	my $field = shift;
	my $flag = shift;

	foreach(@{$show->{'credits'}->{$field}}) {
		$cred_hdl->execute($showid, $_, $flag)
		  or die "cannot insert credits into database";
	}
}

### XMLTV Import ##############################################################

XMLTV::parsefiles_callback(\&encoding_cb, 
			   \&credits_cb, 
			   \&channel_cb, 
			   \&programme_cb,
			   @ARGV);

db_dupscan() if($opt_dupscan);


### DB duplicates scan ########################################################
sub db_dupscan() {
	my @xmltv_chids = ();
	my $deleted = 0;
	
	$sth = $dbh->prepare("SELECT id FROM channels");
	$sth->execute() or die "db_dupscan: cannot select channels";
	push @xmltv_chids, $row[0]
	  while(@row = $sth->fetchrow_array);
	$sth->finish();

	#-- okay, we've got @xmltv_chids now filled with the chids for xmltv-channels
	my $del_prog = $dbh->prepare("DELETE FROM programmes WHERE id=?");
	my $del_cred = $dbh->prepare("DELETE FROM credits WHERE showid=?");
	$sth = $dbh->prepare("SELECT id,begintime FROM programmes WHERE channel=? ORDER BY begintime");
	foreach(@xmltv_chids) {
		$sth->execute($_) or die "db_dupscan: cannot select from programmes";

		my $last = 0;
		while (@row = $sth->fetchrow_array) {
			if ($row[1] == $last) {
				$del_prog->execute($row[0]) or die "db_dupscan: cannot delete from programmes";
				$del_cred->execute($row[0]) or die "db_dupscan: cannot delete from credits";
				$deleted ++;
			} else {
				$last = $row[1];
			}
		}
	}
	$sth->finish();
	$del_prog->finish();
	$del_cred->finish();

	print "db_dupscan: deleted $deleted (duplicate) entries from programmes table.\n" if ($deleted);
}
