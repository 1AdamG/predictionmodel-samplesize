#truncate table runtime_data
#2018-11-21 13:03:13     1
CREATE TABLE `runtime_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `executionID` varchar(14) DEFAULT NULL,
  `repetitionCount` int(11) DEFAULT NULL,
  `numberofupdatingevents` int(11) DEFAULT NULL,
  `developmentprevalence` float DEFAULT NULL,
  `updatingvalidationprevalence` float DEFAULT NULL,
  `numberofupdatingnonevents` int(11) DEFAULT NULL,
  `numberofdevelopmentnonevents` int(11) DEFAULT NULL,
  `numberofvalidationnonevents` int(11) DEFAULT NULL,
  `comparisonResult` float DEFAULT NULL,
  `regdate` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=923737 DEFAULT CHARSET=utf8mb4;
