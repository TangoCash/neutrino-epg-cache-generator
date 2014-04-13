-- --------------------------------------------------------
-- Хост:                         192.168.2.40
-- Версия сервера:               5.5.35-0ubuntu0.12.04.2 - (Ubuntu)
-- ОС Сервера:                   debian-linux-gnu
-- HeidiSQL Версия:              8.3.0.4750
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

CREATE DATABASE IF NOT EXISTS `TVprg` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `TVprg`;

CREATE TABLE IF NOT EXISTS `bookmarks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `showid` int(11) NOT NULL,
  `uid` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uid_showid_index` (`uid`,`showid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `channels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tvuri` tinytext NOT NULL,
  `friendly_name` varchar(40) NOT NULL,
  `download` tinyint(4) NOT NULL,
  `user1` tinyint(4) DEFAULT NULL,
  `user2` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `credits` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `showid` int(10) unsigned NOT NULL,
  `name` tinytext NOT NULL,
  `type` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `showid_index` (`showid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `lschannels-ru` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tvuri` tinytext,
  `tsid` tinytext,
  `onid` tinytext,
  `sid` tinytext,
  `fname` tinytext,
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `programmes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `begintime` int(10) unsigned NOT NULL,
  `endtime` int(10) unsigned NOT NULL,
  `channel` smallint(5) unsigned NOT NULL,
  `title` tinytext NOT NULL,
  `subtitle` tinytext,
  `text` varchar(4096) DEFAULT NULL,
  `category` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `channel_begin_index` (`begintime`,`channel`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) NOT NULL,
  `cookie` text NOT NULL,
  `logintime` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `key_uid_index` (`uid`,`cookie`(5))
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nickname` varchar(20) DEFAULT NULL,
  `email` varchar(40) DEFAULT NULL,
  `chrname` varchar(20) DEFAULT NULL,
  `famname` varchar(20) DEFAULT NULL,
  `passwd` varchar(20) DEFAULT NULL,
  `superuser` tinyint(4) DEFAULT NULL,
  `lang` char(2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `nickname_index` (`nickname`(10))
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
