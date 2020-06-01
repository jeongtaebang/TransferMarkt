-- MySQL dump 10.13  Distrib 8.0.20, for Win64 (x86_64)
--
-- Host: transfermarkt.cdcl1ioqlhoa.us-east-1.rds.amazonaws.com    Database: TransferMarkt_sp20
-- ------------------------------------------------------
-- Server version	8.0.17

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '';

--
-- Table structure for table `Clubs`
--

DROP TABLE IF EXISTS `Clubs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Clubs` (
  `ClubID` int(11) NOT NULL AUTO_INCREMENT,
  `ClubName` varchar(150) NOT NULL,
  `LeagueID` int(11) NOT NULL,
  PRIMARY KEY (`ClubID`),
  KEY `fk_Clubs_League1_idx` (`LeagueID`),
  CONSTRAINT `fk_Clubs_League1` FOREIGN KEY (`LeagueID`) REFERENCES `Leagues` (`LeagueID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Clubs`
--

LOCK TABLES `Clubs` WRITE;
/*!40000 ALTER TABLE `Clubs` DISABLE KEYS */;
INSERT INTO `Clubs` VALUES (1,'FC Barcelona',1),(2,'Atlético Madrid',1),(3,'Real Betis',1),(4,'Granada CF',1),(5,'Real Madrid',1),(6,'Valencia CF',1),(7,'Real Sociedad',1),(8,'Sevilla FC',1),(9,'Villarreal CF',1),(10,'Getafe CF',1),(11,'Athletic Club de Bilbao',1),(12,'CA Osasuna',1),(13,'Levante UD',1),(14,'Deportivo Alavés',1),(15,'Real Valladolid CF',1),(16,'SD Eibar',1),(17,'RC Celta',1),(18,'RCD Mallorca',1),(19,'CD Leganés',1),(20,'RCD Espanyol',1);
/*!40000 ALTER TABLE `Clubs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Leagues`
--

DROP TABLE IF EXISTS `Leagues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Leagues` (
  `LeagueID` int(11) NOT NULL AUTO_INCREMENT,
  `LeagueName` varchar(45) NOT NULL,
  `SalaryCap` int(11) NOT NULL,
  PRIMARY KEY (`LeagueID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Leagues`
--

LOCK TABLES `Leagues` WRITE;
/*!40000 ALTER TABLE `Leagues` DISABLE KEYS */;
INSERT INTO `Leagues` VALUES (1,'La Liga Series A',115000000);
/*!40000 ALTER TABLE `Leagues` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Managers`
--

DROP TABLE IF EXISTS `Managers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Managers` (
  `ManagerID` int(11) NOT NULL AUTO_INCREMENT,
  `AdminPrivilege` int(11) NOT NULL,
  `Username` varchar(45) NOT NULL,
  `SaltedPassword` varchar(300) NOT NULL,
  `ClubID` int(11) NOT NULL,
  PRIMARY KEY (`ManagerID`),
  KEY `fk_Managers_Clubs1_idx` (`ClubID`),
  CONSTRAINT `fk_Managers_Clubs1` FOREIGN KEY (`ClubID`) REFERENCES `Clubs` (`ClubID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Managers`
--

LOCK TABLES `Managers` WRITE;
/*!40000 ALTER TABLE `Managers` DISABLE KEYS */;
INSERT INTO `Managers` VALUES (1,1,'chloeozzy','$2b$12$4NwTIF4j9Nm.4ZVcPABoR.D0fNTpsxpA5GAZB1.FpMOKlADAU62cO',1),(2,1,'muttiesreeping','$2b$12$Rv9VKSZizePoDq97EENURuubkqdkRQ3OjYN.CxziRSq6ofz.PKKY2',2),(3,1,'poppyovercast','$2b$12$S8/YHewCQXw8CmmY6L3RKuiu1AtFfCWPa2Urnc22i734/QNJ.SkWm',3),(4,1,'refluxanthology','$2b$12$CwGectAxbTsMYity8FIUGOTm1Tye2M3mqSh25fCJGBGdpSxgM7ysu',4),(5,1,'ludibriousjump','$2b$12$cvtYpy6MHsksXxi2QenYDuJQOdruEpPIp8ULR0HB74jdUUNB42Hqu',5),(6,1,'wekivadesk','$2b$12$K2izF0OaYGulxWiyrF7obOfCHX6oJB.AY.0yNAKE..YJSbUpL1n7u',6),(7,1,'coalitionpolicy','$2b$12$sRLLdcoaIDOKDqmQ.sLfROQogWEdaaeFKQ0ouyDG2muVKm0EJcxXi',7),(8,1,'crierbedswerver','$2b$12$yo5QrEnNFMjz1sDOacE.iuZ3AaxCJ929v/tOA9.S6p65WeZbNbfyq',8),(9,1,'publishernutcracker','$2b$12$YK3X1z4wnnsoUXY7TzzD.Owd0mC6kHxxg82xeKUC96Vvwshxj2DIG',9),(10,1,'execbusan','$2b$12$7LfcF/YITHIO8IBG2fPk/eH2cNpcozt9oJH4iHFQJ7bxj.RVG40M6',10),(11,1,'booeshairs','$2b$12$hML0YThsvO3ez10s4noGKu4zPG/80dcUBKYVUDXaCLGf2.dRkvzFq',11),(12,1,'pebbleswarming','$2b$12$2mEa.enFXSDx4/F9bj8b5.AiUCzQHn0HyvSJxfC4KBryG14TgxAbq',12),(13,1,'tarffcareers','$2b$12$/qo0Ja3WqudbTHovIhNqUO7T7zOZCfKofSV24I4duc5E8IBNLfWHO',13),(14,1,'irateflotilla','$2b$12$VTWWfCGHcK3d55.rrw5rOOFwgitTJVaPEefvO98n3rPduaVye.F8a',14),(15,1,'villagegregarious','$2b$12$DhRxC3GpFA68MDivmu/P7.3ZsTYL0CgfpzqU.XGPKzTcJL9O7ewcu',15),(16,1,'borsezipping','$2b$12$/YI7AafgoBiSZKk36C/o/.RknfOCAn8vxOdnCko9axA8KsMwWS3fW',16),(17,1,'oppressedelderly','$2b$12$YjxRImK1.zZGo73KqajXbOsyCWb8yrCZGmmwMut5MOumKcyY5Zs/O',17),(18,1,'datastatute','$2b$12$6riPAhui7V.Df9cByFU9H.bcmM9GsvvsnK1gApD3Gvjcgzso0v2Hq',18),(19,1,'chopinenzyme','$2b$12$oUNeG084SFXU.q7LmnHfIuFYr2dobRdsHR5bM3WpbFBPd6vFLjpEC',19),(20,1,'spellingjob','$2b$12$.562jPaohK5mq1mglS9vauZOF5JhsFagwFKORDlNKEvCPuCz5MjDu',20);
/*!40000 ALTER TABLE `Managers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Packages`
--

DROP TABLE IF EXISTS `Packages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Packages` (
  `PackageID` varchar(40) NOT NULL,
  `Status` int(11) NOT NULL,
  `Date` date NOT NULL,
  PRIMARY KEY (`PackageID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Packages`
--

LOCK TABLES `Packages` WRITE;
/*!40000 ALTER TABLE `Packages` DISABLE KEYS */;
INSERT INTO `Packages` VALUES ('04b8cda0-a43a-11ea-93fc-9571883f98ab',1,'2020-06-01'),('8d36d3e0-a424-11ea-b433-ddd3c3c829df',1,'2020-06-01'),('fa1b5f90-a423-11ea-b433-ddd3c3c829df',1,'2020-06-01');
/*!40000 ALTER TABLE `Packages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PlayerPositions`
--

DROP TABLE IF EXISTS `PlayerPositions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `PlayerPositions` (
  `PlayerID` int(11) NOT NULL,
  `PositionID` int(11) NOT NULL,
  PRIMARY KEY (`PlayerID`,`PositionID`),
  KEY `fk_Players_has_Positions_Positions1_idx` (`PositionID`),
  KEY `fk_Players_has_Positions_Players_idx` (`PlayerID`),
  CONSTRAINT `fk_Players_has_Positions_Players` FOREIGN KEY (`PlayerID`) REFERENCES `Players` (`PlayerID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_Players_has_Positions_Positions1` FOREIGN KEY (`PositionID`) REFERENCES `Positions` (`PositionID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PlayerPositions`
--

LOCK TABLES `PlayerPositions` WRITE;
/*!40000 ALTER TABLE `PlayerPositions` DISABLE KEYS */;
INSERT INTO `PlayerPositions` VALUES (18,1),(32,1),(35,1),(37,1),(41,1),(51,1),(64,1),(78,1),(88,1),(96,1),(117,1),(148,1),(161,1),(163,1),(168,1),(189,1),(190,1),(227,1),(228,1),(229,1),(236,1),(257,1),(267,1),(271,1),(273,1),(282,1),(284,1),(290,1),(303,1),(312,1),(325,1),(327,1),(337,1),(339,1),(344,1),(346,1),(352,1),(375,1),(377,1),(392,1),(400,1),(406,1),(430,1),(438,1),(445,1),(449,1),(450,1),(461,1),(500,1),(509,1),(510,1),(511,1),(513,1),(534,1),(552,1),(553,1),(557,1),(558,1),(563,1),(565,1),(566,1),(572,1),(576,1),(587,1),(591,1),(599,1),(606,1),(611,1),(613,1),(6,2),(11,2),(17,2),(22,2),(24,2),(25,2),(38,2),(46,2),(47,2),(49,2),(50,2),(60,2),(67,2),(68,2),(73,2),(76,2),(92,2),(102,2),(105,2),(106,2),(107,2),(121,2),(136,2),(138,2),(140,2),(151,2),(162,2),(165,2),(167,2),(170,2),(172,2),(181,2),(187,2),(188,2),(198,2),(200,2),(202,2),(208,2),(209,2),(211,2),(213,2),(218,2),(226,2),(234,2),(235,2),(240,2),(243,2),(244,2),(249,2),(255,2),(256,2),(261,2),(264,2),(266,2),(272,2),(276,2),(277,2),(281,2),(293,2),(300,2),(306,2),(311,2),(315,2),(317,2),(348,2),(350,2),(356,2),(360,2),(362,2),(364,2),(367,2),(369,2),(370,2),(379,2),(386,2),(388,2),(394,2),(402,2),(404,2),(407,2),(412,2),(419,2),(427,2),(428,2),(436,2),(439,2),(441,2),(443,2),(457,2),(458,2),(466,2),(468,2),(469,2),(481,2),(484,2),(485,2),(489,2),(491,2),(514,2),(519,2),(521,2),(523,2),(526,2),(527,2),(531,2),(538,2),(542,2),(545,2),(547,2),(555,2),(560,2),(561,2),(571,2),(577,2),(579,2),(596,2),(598,2),(607,2),(609,2),(610,2),(623,2),(8,3),(13,3),(19,3),(21,3),(36,3),(45,3),(51,3),(53,3),(59,3),(71,3),(79,3),(83,3),(87,3),(90,3),(94,3),(101,3),(104,3),(109,3),(123,3),(130,3),(131,3),(132,3),(155,3),(160,3),(162,3),(164,3),(168,3),(172,3),(175,3),(177,3),(179,3),(180,3),(182,3),(191,3),(199,3),(201,3),(206,3),(213,3),(214,3),(215,3),(219,3),(234,3),(242,3),(251,3),(252,3),(258,3),(259,3),(266,3),(271,3),(273,3),(275,3),(283,3),(284,3),(286,3),(288,3),(305,3),(308,3),(311,3),(312,3),(313,3),(316,3),(322,3),(324,3),(327,3),(331,3),(333,3),(336,3),(337,3),(348,3),(355,3),(357,3),(365,3),(366,3),(387,3),(392,3),(402,3),(418,3),(421,3),(442,3),(443,3),(444,3),(450,3),(451,3),(462,3),(473,3),(486,3),(487,3),(493,3),(500,3),(512,3),(528,3),(532,3),(546,3),(553,3),(556,3),(559,3),(576,3),(610,3),(1,4),(3,4),(9,4),(14,4),(37,4),(82,4),(91,4),(108,4),(231,4),(302,4),(344,4),(416,4),(430,4),(541,4),(565,4),(5,5),(8,5),(12,5),(18,5),(19,5),(20,5),(21,5),(23,5),(31,5),(32,5),(34,5),(36,5),(37,5),(45,5),(51,5),(53,5),(59,5),(66,5),(71,5),(72,5),(78,5),(79,5),(83,5),(85,5),(87,5),(88,5),(90,5),(93,5),(101,5),(104,5),(109,5),(118,5),(123,5),(130,5),(131,5),(132,5),(144,5),(155,5),(160,5),(161,5),(162,5),(163,5),(164,5),(166,5),(168,5),(169,5),(175,5),(177,5),(179,5),(180,5),(182,5),(191,5),(199,5),(201,5),(206,5),(213,5),(214,5),(215,5),(219,5),(228,5),(229,5),(234,5),(242,5),(251,5),(252,5),(257,5),(258,5),(259,5),(271,5),(273,5),(275,5),(283,5),(284,5),(286,5),(288,5),(290,5),(294,5),(301,5),(305,5),(308,5),(312,5),(313,5),(316,5),(322,5),(324,5),(327,5),(333,5),(336,5),(337,5),(346,5),(348,5),(352,5),(355,5),(357,5),(359,5),(365,5),(366,5),(380,5),(387,5),(392,5),(400,5),(401,5),(418,5),(421,5),(438,5),(442,5),(444,5),(446,5),(449,5),(450,5),(451,5),(455,5),(456,5),(461,5),(462,5),(473,5),(487,5),(500,5),(511,5),(524,5),(528,5),(535,5),(539,5),(545,5),(546,5),(557,5),(564,5),(566,5),(569,5),(576,5),(587,5),(588,5),(591,5),(599,5),(615,5),(626,5),(2,6),(4,6),(10,6),(16,6),(26,6),(48,6),(61,6),(62,6),(63,6),(80,6),(81,6),(86,6),(111,6),(113,6),(114,6),(152,6),(171,6),(174,6),(205,6),(212,6),(225,6),(232,6),(233,6),(241,6),(245,6),(246,6),(289,6),(291,6),(328,6),(330,6),(345,6),(351,6),(395,6),(409,6),(423,6),(433,6),(435,6),(447,6),(453,6),(496,6),(498,6),(499,6),(501,6),(502,6),(503,6),(529,6),(530,6),(533,6),(537,6),(540,6),(554,6),(567,6),(573,6),(574,6),(575,6),(580,6),(582,6),(586,6),(605,6),(608,6),(614,6),(616,6),(617,6),(624,6),(625,6),(627,6),(15,7),(29,7),(67,7),(77,7),(95,7),(120,7),(133,7),(136,7),(145,7),(147,7),(150,7),(184,7),(192,7),(193,7),(218,7),(221,7),(238,7),(239,7),(248,7),(263,7),(270,7),(278,7),(296,7),(307,7),(310,7),(319,7),(320,7),(332,7),(353,7),(354,7),(356,7),(361,7),(363,7),(370,7),(371,7),(373,7),(378,7),(381,7),(383,7),(405,7),(411,7),(413,7),(420,7),(422,7),(452,7),(463,7),(472,7),(480,7),(485,7),(489,7),(504,7),(515,7),(536,7),(578,7),(584,7),(602,7),(620,7),(622,7),(623,7),(23,8),(31,8),(40,8),(41,8),(55,8),(71,8),(75,8),(83,8),(96,8),(98,8),(110,8),(112,8),(125,8),(126,8),(130,8),(133,8),(135,8),(139,8),(142,8),(144,8),(148,8),(149,8),(150,8),(153,8),(156,8),(157,8),(163,8),(169,8),(178,8),(186,8),(189,8),(191,8),(195,8),(203,8),(207,8),(227,8),(230,8),(236,8),(239,8),(253,8),(260,8),(263,8),(265,8),(267,8),(270,8),(274,8),(282,8),(290,8),(294,8),(295,8),(297,8),(302,8),(303,8),(310,8),(316,8),(318,8),(321,8),(323,8),(326,8),(338,8),(353,8),(370,8),(371,8),(374,8),(375,8),(376,8),(377,8),(382,8),(384,8),(396,8),(400,8),(408,8),(417,8),(426,8),(432,8),(437,8),(445,8),(454,8),(456,8),(461,8),(472,8),(474,8),(478,8),(483,8),(490,8),(510,8),(511,8),(522,8),(534,8),(535,8),(539,8),(544,8),(585,8),(590,8),(593,8),(594,8),(595,8),(600,8),(602,8),(603,8),(618,8),(620,8),(3,9),(9,9),(18,9),(28,9),(33,9),(42,9),(55,9),(64,9),(98,9),(129,9),(139,9),(142,9),(157,9),(178,9),(186,9),(189,9),(195,9),(197,9),(203,9),(207,9),(224,9),(274,9),(340,9),(343,9),(363,9),(378,9),(408,9),(411,9),(430,9),(431,9),(440,9),(467,9),(492,9),(507,9),(522,9),(524,9),(558,9),(570,9),(606,9),(621,9),(133,10),(239,10),(296,10),(320,10),(354,10),(361,10),(439,10),(578,10),(27,11),(56,11),(66,11),(67,11),(70,11),(76,11),(99,11),(118,11),(122,11),(127,11),(141,11),(151,11),(154,11),(159,11),(167,11),(173,11),(176,11),(183,11),(185,11),(202,11),(204,11),(214,11),(218,11),(243,11),(254,11),(255,11),(262,11),(280,11),(287,11),(292,11),(299,11),(300,11),(314,11),(334,11),(335,11),(338,11),(341,11),(347,11),(349,11),(358,11),(363,11),(364,11),(385,11),(391,11),(403,11),(405,11),(407,11),(410,11),(414,11),(419,11),(422,11),(425,11),(429,11),(434,11),(459,11),(463,11),(465,11),(473,11),(479,11),(482,11),(484,11),(485,11),(506,11),(543,11),(549,11),(568,11),(571,11),(592,11),(604,11),(607,11),(622,11),(23,12),(31,12),(32,12),(41,12),(57,12),(59,12),(66,12),(70,12),(89,12),(93,12),(96,12),(108,12),(112,12),(118,12),(119,12),(125,12),(126,12),(134,12),(144,12),(148,12),(151,12),(153,12),(154,12),(156,12),(159,12),(169,12),(176,12),(178,12),(190,12),(210,12),(216,12),(217,12),(219,12),(227,12),(231,12),(254,12),(257,12),(260,12),(262,12),(268,12),(279,12),(282,12),(285,12),(288,12),(292,12),(295,12),(297,12),(302,12),(304,12),(314,12),(321,12),(323,12),(325,12),(326,12),(338,12),(347,12),(352,12),(368,12),(372,12),(374,12),(375,12),(376,12),(377,12),(396,12),(406,12),(414,12),(416,12),(417,12),(437,12),(445,12),(454,12),(474,12),(477,12),(478,12),(479,12),(483,12),(488,12),(508,12),(509,12),(510,12),(513,12),(516,12),(534,12),(539,12),(544,12),(548,12),(552,12),(572,12),(583,12),(590,12),(593,12),(594,12),(603,12),(611,12),(1,13),(28,13),(30,13),(33,13),(42,13),(55,13),(58,13),(78,13),(89,13),(125,13),(134,13),(135,13),(161,13),(183,13),(224,13),(229,13),(231,13),(304,13),(343,13),(398,13),(470,13),(477,13),(488,13),(492,13),(495,13),(507,13),(517,13),(551,13),(558,13),(570,13),(606,13),(612,13),(122,14),(204,14),(254,14),(299,14),(314,14),(335,14),(341,14),(347,14),(385,14),(391,14),(405,14),(429,14),(479,14),(1,15),(7,15),(9,15),(14,15),(28,15),(30,15),(39,15),(40,15),(43,15),(44,15),(52,15),(54,15),(57,15),(58,15),(65,15),(69,15),(74,15),(75,15),(82,15),(84,15),(91,15),(97,15),(100,15),(103,15),(108,15),(110,15),(112,15),(115,15),(116,15),(124,15),(128,15),(135,15),(137,15),(139,15),(142,15),(143,15),(146,15),(149,15),(158,15),(194,15),(196,15),(207,15),(210,15),(216,15),(217,15),(220,15),(222,15),(223,15),(224,15),(237,15),(247,15),(250,15),(253,15),(267,15),(269,15),(274,15),(279,15),(295,15),(297,15),(298,15),(303,15),(309,15),(318,15),(325,15),(329,15),(340,15),(342,15),(344,15),(368,15),(372,15),(382,15),(384,15),(389,15),(390,15),(393,15),(397,15),(398,15),(399,15),(406,15),(415,15),(424,15),(431,15),(437,15),(440,15),(448,15),(456,15),(460,15),(464,15),(467,15),(471,15),(474,15),(475,15),(476,15),(483,15),(490,15),(492,15),(494,15),(495,15),(497,15),(505,15),(507,15),(508,15),(509,15),(516,15),(518,15),(520,15),(525,15),(541,15),(550,15),(562,15),(570,15),(581,15),(585,15),(589,15),(593,15),(597,15),(601,15),(612,15),(619,15);
/*!40000 ALTER TABLE `PlayerPositions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Players`
--

DROP TABLE IF EXISTS `Players`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Players` (
  `PlayerID` int(11) NOT NULL AUTO_INCREMENT,
  `FirstName` varchar(30) NOT NULL,
  `LastName` varchar(30) NOT NULL,
  `Age` int(11) NOT NULL,
  `Salary` int(11) NOT NULL,
  `ClubID` int(11) NOT NULL,
  PRIMARY KEY (`PlayerID`),
  KEY `fk_Players_Clubs1_idx` (`ClubID`),
  CONSTRAINT `fk_Players_Clubs1` FOREIGN KEY (`ClubID`) REFERENCES `Clubs` (`ClubID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=628 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Players`
--

LOCK TABLES `Players` WRITE;
/*!40000 ALTER TABLE `Players` DISABLE KEYS */;
INSERT INTO `Players` VALUES (1,'Lionel','Andres Messi Cuccittini',33,11104811,1),(2,'Jan','Oblak',26,200000,1),(3,'Eden','Hazard',28,8068481,5),(4,'Marc-Andre','ter Stegen',27,7253572,1),(5,'Luka','Modric',33,7253572,5),(6,'Sergio','Ramos Garcia',33,6520969,5),(7,'Luis','Alberto Suarez Diaz',32,6520969,1),(8,'Sergio','Busquets i Burgos',30,20000,2),(9,'Antoine','Griezmann',28,6520969,1),(10,'Thibaut','Courtois',27,5862358,5),(11,'Gerard','Pique Bernabeu',32,5862358,1),(12,'Toni','Kroos',29,5862358,5),(13,'Carlos','Henrique Venancio Casimiro',27,5270266,5),(14,'Karim','Benzema',31,5270266,5),(15,'Jordi','Alba Ramos',30,5270266,1),(16,'Keylor','Navas',32,5270266,5),(17,'Samuel','Umtiti',25,4737975,1),(18,'Francisco','Roman Alarcon Suarez',27,4737975,5),(19,'Ivan','Rakitic',31,4737975,1),(20,'Daniel','Parejo Munoz',30,4737975,6),(21,'Frenkie','de Jong',22,4259444,1),(22,'Raphael','Varane',26,4259444,5),(23,'Saul','Niguez Esclapez',24,4259444,2),(24,'Jose','Maria Gimenez de Vargas',24,4259444,2),(25,'Clement','Lenglet',24,4259444,1),(26,'Norberto','Murara Neto',29,4259444,1),(27,'Daniel','Carvajal Ramos',27,4259444,5),(28,'Gareth','Frank Bale',29,4259444,5),(29,'Marcelo','Vieira da Silva Junior',31,4259444,5),(30,'Iago','Aspas Juncal',31,4259444,17),(31,'Jorge','Resurreccion Merodio',27,4259444,2),(32,'James','David Rodriguez Rubio',27,4259444,5),(33,'Ousmane','Dembele',22,3829245,1),(34,'Arthur','Henrique Ramos Oliveira Melo',22,3829245,1),(35,'Nabil','Fekir',25,3829245,3),(36,'Arturo','Vidal',32,3829245,1),(37,'Sergio','Canales Madrazo',28,3829245,3),(38,'Felipe','Augusto de Almeida Monteiro',30,3829245,2),(39,'Luka','Jovic',21,3442495,5),(40,'Goncalo','Manuel Ganchinho Guedes',22,3442495,6),(41,'Thomas','Lemar',23,3442495,2),(42,'Marco','Asensio Willemsen',23,3442495,5),(43,'Borja','Iglesias Quintas',26,3442495,3),(44,'Alvaro','Borja Morata Martin',26,3442495,2),(45,'William','Silva de Carvalho',27,3442495,3),(46,'Djene','Dakonam Ortega',27,3442495,10),(47,'Marc','Bartra Aregall',28,3442495,3),(48,'Jasper','Cillessen',30,3442495,6),(49,'Raul','Albiol Tortajada',33,3442495,9),(50,'Ezequiel','Marcelo Garay',32,3442495,6),(51,'Ever','Maximiliano David Banega',31,3442495,8),(52,'Diego','da Silva Costa',30,3442495,2),(53,'Asier','Illarramendi Andonegi',29,3442495,7),(54,'Rodrigo','Moreno Machado',28,3442495,6),(55,'Mikel','Oyarzabal Ugarte',22,3094807,7),(56,'Nelson','Cabral Semedo',25,3094807,1),(57,'Angel','Correa',24,3094807,2),(58,'Inaki','Williams Arthuer',25,3094807,11),(59,'Thomas','Partey',26,3094807,2),(60,'Stefan','Savic',28,3094807,2),(61,'Fernando','Pacheco Flores',27,3094807,14),(62,'David','Soria Solis',26,3094807,10),(63,'Sergio','Asenjo Andres',30,3094807,9),(64,'Iker','Muniain Goni',26,3094807,11),(65,'Willian','Jose da Silva',27,3094807,7),(66,'Sergio','Roberto Carnicer',27,3094807,1),(67,'Jose','Ignacio Fernandez Iglesias',29,3094807,5),(68,'Gabriel','Armando de Abreu',28,3094807,6),(69,'Aritz','Aduriz Zubeldia',38,3094807,11),(70,'Jesus','Navas Gonzalez',33,3094807,8),(71,'Santiago','Cazorla Gonzalez',34,3094807,9),(72,'Hector','Miguel Herrera Lopez',29,3094807,2),(73,'Simon','Thorup Kjaer',30,3094807,8),(74,'Luuk','de Jong',28,3094807,8),(75,'Jose','Luis Morales Nogales',31,3094807,13),(76,'Eder','Gabriel Militao',21,2782234,5),(77,'Jose','Luis Gaya Pena',24,2782234,6),(78,'Rafael','Alcantara do Nascimento',26,2782234,1),(79,'Geoffrey','Kondogbia',26,2782234,6),(80,'Jordi','Masip Lopez',30,2782234,15),(81,'Tomas','Vaclik',30,2782234,8),(82,'Gerard','Moreno Balaguero',27,2782234,9),(83,'Jose','Andres Guardado Hernandez',32,2782234,3),(84,'Kevin','Gameiro',32,2782234,6),(85,'Benat','Etxebarria Urkiaga',32,2782234,11),(86,'Antonio','Adan Garrido',32,2782234,2),(87,'Fernando','Francisco Reges',31,2782234,8),(88,'Franco','Vazquez',30,2782234,8),(89,'Lucas','Vazquez Iglesias',28,2782234,5),(90,'Daniel','Garcia Carrillo',29,2782234,11),(91,'Joao','Felix Sequeira',19,2501232,2),(92,'Mario','Hermoso Canseco',24,2501232,2),(93,'Carlos','Soler Barragan',22,2501232,6),(94,'Marcos','Llorente Moreno',24,2501232,2),(95,'Ferland','Mendy',24,2501232,5),(96,'Oscar','Melendo Jimenez',21,2501232,20),(97,'Santiago','Mina Lorenzo',23,2501232,17),(98,'Marcos','Paulo Mesquita Lopes',23,2501232,8),(99,'Alvaro','Odriozola Arzalluz',23,2501232,5),(100,'Maximiliano','Gomez',22,2501232,6),(101,'Sergi','Darder Moll',25,2501232,20),(102,'Yeray','Alvarez Lopez',24,2501232,11),(103,'Lorenzo','Moron Garcia',25,2501232,3),(104,'Jose','Angel Gomez Campana',26,2501232,13),(105,'Aissa','Mandi',27,2501232,3),(106,'Sergi','Gomez Sola',27,2501232,8),(107,'Inigo','Martinez Berridi',28,2501232,11),(108,'Cristian','Portugues Manzanera',27,2501232,7),(109,'Manuel','Trigueros Munoz',27,2501232,9),(110,'Moanes','Dabour',27,2501232,8),(111,'Marko','Dmitrovic',27,2501232,16),(112,'Joaquin','Sanchez Rodriguez',37,2501232,3),(113,'Miguel','Angel Moya Rumbo',35,2501232,7),(114,'Diego','Lopez Rodriguez',37,2501232,20),(115,'Jorge','Molina Vidal',37,2501232,10),(116,'Charles','Dias De Oliveira',35,2501232,16),(117,'Raul','Garcia Escudero',32,2501232,11),(118,'Daniel','Wass',30,2501232,6),(119,'Pedro','Leon Sanchez Gil',32,2501232,16),(120,'Vitorino','Gabriel Pacheco Antunes',32,2501232,10),(121,'Sidnei','Rechel da Silva Junior',29,2501232,3),(122,'Kieran','Trippier',28,2501232,2),(123,'Francis','Coquelin',28,2501232,6),(124,'Sergio','Enrich Ametller',29,2501232,16),(125,'Ibai','Gomez Perez',29,2501232,11),(126,'Cristian','Tello Herrera',27,2501232,3),(127,'Sime','Vrsaljko',27,2501232,2),(128,'Jaime','Mata Arnaiz',30,2501232,10),(129,'Vinicius','Jose de Oliveira Junior',18,2248610,5),(130,'Mikel','Merino Zazon',23,2248610,7),(131,'Marc','Roca Junque',22,2248610,20),(132,'Stanislav','Lobotka',24,2248610,17),(133,'Hector','Junior Firpo Adames',22,2248610,1),(134,'Adnan','Januzaj',24,2248610,7),(135,'Munir','El Haddadi',23,2248610,8),(136,'Leandro','Cabrera',27,2248610,10),(137,'Mariano','Diaz Mejia',25,2248610,5),(138,'Diego','Carlos Santos Silva',26,2248610,8),(139,'Karl','Brillant Toko Ekambi',26,2248610,9),(140,'Victor','Laguardia Cisneros',29,2248610,14),(141,'Santiago','Arias Naranjo',27,2248610,2),(142,'Wu Lei ','',27,2248610,20),(143,'Angel','Luis Rodriguez Diaz',32,2248610,10),(144,'Esteban','Felix Granero Molina',31,2248610,20),(145,'Yuri','Berchiche Izeta',29,2248610,11),(146,'Nikola','Kalinic',31,2248610,2),(147,'Jose','Angel Valdes Diaz',29,2248610,16),(148,'Fabian','Orellana',33,2248610,16),(149,'Enrique','Garcia Martinez',29,2248610,16),(150,'Sergio','Escudero Palomo',29,2248610,8),(151,'Mario','Gaspar Perez Martinez',28,2248610,9),(152,'Iago','Herrerin Buisan',31,2248610,11),(153,'Victor','Machin Perez',29,2248610,2),(154,'Damian','Nicolas Suarez Suarez',31,2248610,10),(155,'Roque','Mesa Quevedo',30,2248610,19),(156,'Gan ','Gui Shi ',31,2248610,16),(157,'Denis','Cheryshev',28,2248610,6),(158,'Carlos','Arturo Bacca Ahumada',32,2248610,9),(159,'Ruben','Pena Jimenez',27,2248610,9),(160,'Ruben','Alcaraz Jimenez',28,2248610,15),(161,'Martin','Odegaard',20,2021502,7),(162,'Okay','Yokuslu',25,2021502,17),(163,'Enis','Bardhi',23,2021502,13),(164,'Nemanja','Maksimovic',24,2021502,10),(165,'Fernando','Calero Villa',23,2021502,20),(166,'Oliver','Torres Munoz',24,2021502,8),(167,'Ruben','Miguel Nunes Vezo',25,2021502,13),(168,'Joan','Jordan Moreno',24,2021502,8),(169,'Denis','Suarez Fernandez',25,2021502,17),(170,'Guillermo','Alfonso Maripan Loaysa',25,2021502,14),(171,'Joel','Robles Blazquez',29,2021502,3),(172,'David','Lopez Silva',29,2021502,20),(173,'Ander','Capa Rodriguez',27,2021502,11),(174,'Andres','Eduardo Fernandez Moreno',32,2021502,9),(175,'Manuel','Alejandro Garcia Sanchez',33,2021502,14),(176,'Jorge','Andujar Moreno',32,2021502,13),(177,'Papa','Kouly Diop',33,2021502,16),(178,'Pablo','Daniel Piatti',30,2021502,20),(179,'Bruno','Soriano Llido',35,2021502,9),(180,'Mikel','San Jose Dominguez',30,2021502,11),(181,'Daniel','Filipe Martins Carrico',30,2021502,8),(182,'Vicente','Iborra de la Fuente',31,2021502,9),(183,'Oscar','de Marcos Arana',30,2021502,11),(184,'Jaume','Vicent Costa Jorda',31,2021502,6),(185,'Hugo','Mallo Novegil',28,2021502,17),(186,'Manuel','Agudo Duran',32,2021502,8),(187,'Edinaldo','Gomes Pereira',30,2021502,20),(188,'Zouhair','Feddal',29,2021502,3),(189,'Matias','Vargas',22,1817333,20),(190,'Brais','Mendez Portela',22,1817333,17),(191,'Federico','Valverde',20,1817333,5),(192,'Sergio','Reguilon Rodriguez',22,1817333,8),(193,'Renan','Augusto Lodi dos Santos',21,1817333,2),(194,'Enes','Unal',22,1817333,15),(195,'Pione','Sisto Ifolo Emirmija',24,1817333,17),(196,'Borja','Mayoral Moya',22,1817333,13),(197,'Inigo','Cordoba Kerejeta',22,1817333,11),(198,'Diego','Javier Llorente Rios',25,1817333,7),(199,'Gonzalo','Escalante',26,1817333,16),(200,'Mouctar','Diakhaby',22,1817333,6),(201,'Mauro','Wilney Arambarri Rosa',23,1817333,10),(202,'Aritz','Elustondo',25,1817333,7),(203,'Lucas','Ocampos',24,1817333,8),(204,'Cristiano','Piccini',26,1817333,6),(205,'Sergio','Rico Gonzalez',25,1817333,8),(206,'Nemanja','Gudelj',27,1817333,8),(207,'Juan','Miguel Jimenez Lopez',26,1817333,3),(208,'Jose','Ramiro Funes Mori',28,1817333,9),(209,'Bruno','Gonzalez Cabrera',29,1817333,10),(210,'Ruben','Sobrino Pozuelo',27,1817333,6),(211,'Ivan','Ramis Barrios',34,1817333,16),(212,'Ivan','Cuellar Sacristan',35,1817333,19),(213,'Francisco','Javier Garcia Fernandez',32,1817333,3),(214,'Victor','Sanchez Mata',31,1817333,20),(215,'Tomas','Pina Isla',31,1817333,14),(216,'Sergio','Leon Limones',30,1817333,13),(217,'Lucas','Perez Martinez',30,1817333,14),(218,'Anaitz','Arbilla Zabala',32,1817333,16),(219,'Faycal','Fajr',30,1817333,10),(220,'Roger','Marti Salvador',28,1817333,13),(221,'Jose','Ignacio Martinez Garcia',30,1817333,15),(222,'Facundo','Ferreyra',28,1817333,20),(223,'Sergio','Guardiola Navarro',28,1817333,15),(224,'Rodrygo','Silva de Goes',18,1633784,5),(225,'Andriy','Lunin',20,1633784,15),(226,'Jules','Kounde',20,1633784,8),(227,'igangin','Kangin Lee',18,1633784,6),(228,'Eduardo','Exposito Jaen',22,1633784,16),(229,'Carles','Alena Castillo',21,1633784,1),(230,'Amath','Ndiaye',22,1633784,10),(231,'Samuel','Chukwueze',20,1633784,9),(232,'Alejandro','Remiro Gargallo',24,1633784,7),(233,'Ruben','Blanco Veiga',23,1633784,17),(234,'Igor','Zubeldia Elorza',22,1633784,7),(235,'Unai','Nunez Gestoso',22,1633784,11),(236,'Laureano','Antonio Villa Suarez',24,1633784,15),(237,'Youssef','En-Nesyri',22,1633784,19),(238,'Ruben','Duarte Sanchez',23,1633784,14),(239,'Alfonso','Pedraza Sag',23,1633784,3),(240,'Nestor','Alejandro Araujo Razo',27,1633784,17),(241,'Aitor','Fernandez',28,1633784,13),(242,'Pere','Pons Riera',26,1633784,14),(243,'Unai','Bustinza Martinez',27,1633784,19),(244,'Eliaquim','Mangala',28,1633784,6),(245,'Jaume','Domenech Sanchez',28,1633784,6),(246,'Leandro','Chichizola',29,1633784,10),(247,'John','Guidetti',27,1633784,14),(248,'Alberto','Moreno Perez',26,1633784,9),(249,'Paulo','Andre Rodrigues Oliveira',27,1633784,16),(250,'Roberto','Soldado Rillo',34,1633784,4),(251,'Markel','Bergara Larranaga',33,1633784,10),(252,'David','Zurutuza Veillet',32,1633784,7),(253,'Adrian','Lopez Alvarez',31,1633784,12),(254,'Roberto','Rosales',30,1633784,19),(255,'Facundo','Sebastian Roncaglia',32,1633784,12),(256,'Francisco','Jose Olivas Alba',30,1633784,15),(257,'Ruben','Rochina Naixes',28,1633784,13),(258,'Ander','Iturraspe Derteano',30,1633784,20),(259,'Ruben','Salvador Perez del Marmol',30,1633784,19),(260,'Francisco','Portillo Soler',29,1633784,10),(261,'Raul','Rodriguez Navas',31,1633784,12),(262,'Aleix','Vidal Parreu',29,1633784,14),(263,'Antonio','Garcia Aranda',29,1633784,13),(264,'Dimitrios','Siovas',30,1633784,19),(265,'Alexander','Szymanowski',30,1633784,19),(266,'Oscar','Duarte',30,1633784,13),(267,'Manuel','Vallejo Galvan',22,1468774,6),(268,'Ferran','Torres Garcia',19,1468774,6),(269,'Carlos','Fernandez Luna',23,1468774,4),(270,'Marc','Cucurella Saseta',20,1468774,10),(271,'Francisco','Jose Beltran Peinado',20,1468774,17),(272,'Kenneth','Josiah Omeruo',25,1468774,19),(273,'Anuar','Mohamed Tuhami',24,1468774,15),(274,'Sandro','Ramirez Castillo',23,1468774,15),(275,'Gonzalo','Julian Melero Manzanares',25,1468774,13),(276,'Joris','Gnagnon',22,1468774,8),(277,'Erick','Cabaco',24,1468774,13),(278,'Lucas','Rene Olaza Catrofe',24,1468774,17),(279,'Ezequiel','Avila',25,1468774,12),(280,'Martin','Aguirregabiria',23,1468774,14),(281,'Rodrigo','Ely',25,1468774,14),(282,'Federico','Vico Villegas',24,1468774,4),(283,'Sergio','Alvarez Diaz',27,1468774,16),(284,'Alvaro','Medran Just',25,1468774,6),(285,'David','Jason Remeseiro Salgueiro',24,1468774,6),(286,'Nikola','Vukcevic',27,1468774,13),(287,'Joseba','Zaldua Bengoetxea',27,1468774,7),(288,'Darko','Brasanac',27,1468774,12),(289,'Mariano','Damian Barbosa',34,1468774,9),(290,'Salvador','Sevilla Lopez',35,1468774,18),(291,'Sergio','Alvarez Conde',32,1468774,17),(292,'Antonio','Barragan Fernandez',32,1468774,3),(293,'Bernardo','Jose Espinosa Zuniga',29,1468774,20),(294,'Mubarak','Wakaso',28,1468774,14),(295,'Enrique','Gonzalez Casin',29,1468774,16),(296,'Didac','Vila Rossello',30,1468774,20),(297,'Junior','Wakalibille Lago',28,1468774,18),(298,'Martin','Braithwaite',28,1468774,19),(299,'Javier','Lopez Rodriguez',33,1468774,20),(300,'Joaquin','Navarro Jimenez',29,1468774,14),(301,'Jose','Luis Garcia del Pozo',28,1468774,19),(302,'Oscar','Plano Pedreno',28,1468774,15),(303,'Darwin','Machis',26,1468774,4),(304,'Hernani','Jorge Santos Fortes',27,1468774,13),(305,'Daniel','Alejandro Torres Rojas',29,1468774,14),(306,'Sergio','Postigo Redondo',30,1468774,13),(307,'Adria','Giner Pedrosa',21,1320429,20),(308,'Pape','Cheikh Diop Gueye',21,1320429,17),(309,'Alexander','Isak',19,1320429,7),(310,'Mathias','Olivera Miramontes',21,1320429,10),(311,'Joaquin','Fernandez Moreno',23,1320429,15),(312,'Aleix','Febas Perez',23,1320429,18),(313,'Santiago','Caseres',22,1320429,9),(314,'Francisco','Javier Guerrero Martin',23,1320429,3),(315,'Chidozie','Collins Awaziem',22,1320429,19),(316,'Unai','Lopez Cabrera',23,1320429,11),(317,'Joseph','Aidoo',23,1320429,17),(318,'Waldo','Rubio Martin',23,1320429,15),(319,'Kevin','Manuel Rodrigues',25,1320429,7),(320,'Jonathan','Silva',25,1320429,19),(321,'Alvaro','Vadillo Cifuentes',24,1320429,4),(322,'Sanjin','Prcic',25,1320429,13),(323,'Ivan','Alejo Peralta',24,1320429,10),(324,'Lucas','Silva Borges',26,1320429,5),(325,'Ruben','Garcia Santos',25,1320429,12),(326,'Jorge','Franco Alviz',25,1320429,14),(327,'Ruben','Pardo Gutierrez',26,1320429,7),(328,'Oier','Olazabal Paredes',29,1320429,13),(329,'Jose','Luis Sanmartin Mato',29,1320429,14),(330,'Yoel','Rodriguez Oterino',30,1320429,16),(331,'Angel','Montoro Sanchez',31,1320429,4),(332,'Mikel','Balenziaga Oruesagasti',31,1320429,11),(333,'Miguel','Alfonso Herrero Javaloyas',30,1320429,15),(334,'Sebastien','Corchia',28,1320429,8),(335,'Allan','Nyom',31,1320429,10),(336,'Inigo','Perez Soto',31,1320429,12),(337,'Jozabed','Sanchez Ruiz',28,1320429,17),(338,'Pablo','De Blasis',31,1320429,16),(339,'Javier','Eraso Goni',29,1320429,19),(340,'Sabin','Merino Zuloaga',27,1320429,19),(341,'Jorge','Miramon Santagertrudis',30,1320429,13),(342,'Enrique','Gallego Puigsech',32,1320429,10),(343,'Brahim','Diaz',19,1187067,5),(344,'Javier','Puado Diaz',21,1187067,20),(345,'Unai','Simon Mendibil',22,1187067,11),(346,'Oscar','Rodriguez Arnaiz',21,1187067,19),(347,'Pedro','Antonio Porro Sauceda',19,1187067,15),(348,'Federico','San Emeterio Diaz',22,1187067,15),(349,'Alvaro','Tejero Sacristan',22,1187067,16),(350,'Pau','Francisco Torres',22,1187067,9),(351,'Antonio','Sivera Salva',22,1187067,14),(352,'Luca','Sangalli Fuentes',24,1187067,7),(353,'Guilherme','Arana Lopes',22,1187067,8),(354,'David','Junca Rene',25,1187067,17),(355,'Moises','Gomez Bordonado',25,1187067,9),(356,'Federico','Barba',25,1187067,15),(357,'Andre-Franck','Zambo Anguissa',23,1187067,9),(358,'Marc','Navarro Ceciliano',23,1187067,19),(359,'Mikel','Vesga Arruti',26,1187067,11),(360,'Antonio','Jose Raillo Arenas',27,1187067,18),(361,'Carlos','Clerc Martinez',27,1187067,13),(362,'Pedro','Bigas Rigo',28,1187067,16),(363,'Inigo','Lekue Martinez',26,1187067,11),(364,'Victor','David Diaz Miguel',31,1187067,4),(365,'Francisco','Merida Perez',29,1187067,12),(366,'Oier','Sanjurjo Mate',33,1187067,12),(367,'Xabier','Etxeita Gorritxategi',31,1187067,10),(368,'Juan','Villar Vazquez',31,1187067,12),(369,'German','Sanchez Barahona',32,1187067,4),(370,'Raul','Garcia Carnero',30,1187067,10),(371,'Antonio','Manuel Luna Rodriguez',28,1187067,13),(372,'Pablo','Chavarria',31,1187067,18),(373,'Alejandro','Martinez Sanchez',28,1187067,4),(374,'Pablo','Hervias Rubio',26,1187067,15),(375,'Roberto','Torres Morales',30,1187067,12),(376,'Antonio','Jose Rodriguez Diaz',27,1187067,4),(377,'Diego','Lainez Leyva',19,1067174,3),(378,'Aihen','Munoz Capellan',21,1067174,7),(379,'Jorge','Saenz de Miera',22,1067174,17),(380,'Manuel','Morlanes Arino',20,1067174,9),(381,'Adrian','Marin Gomez',22,1067174,14),(382,'Brandon','Thomas Llamas',24,1067174,12),(383,'Saul','Garcia Cabrero',24,1067174,14),(384,'Marc','Cardona Rovira',23,1067174,12),(385,'Ignacio','Vidal Miralles',24,1067174,12),(386,'Domingos','Sousa Coutinho Meneses Duarte',24,1067174,4),(387,'Cheick','Doukoure',26,1067174,13),(388,'David','Costas Cordal',24,1067174,17),(389,'Juan','Munoz Munoz',23,1067174,19),(390,'Gabriel','Fernandez',25,1067174,17),(391,'Ivan','Lopez Mendoza',25,1067174,13),(392,'Ramon','Olamilekan Azeez',26,1067174,4),(393,'Alexander','Alegria Moreno',26,1067174,18),(394,'Aleksandar','Sedlar',27,1067174,18),(395,'Sergio','Herrera Piron',26,1067174,12),(396,'Roberto','Ibanez Castro',26,1067174,12),(397,'Gustavo','Adrian Ramos Vasquez',33,1067174,4),(398,'Claudio','Beauvue',31,1067174,17),(399,'Ante','Budimir',27,1067174,18),(400,'Daniel','Jose Rodriguez Vazquez',31,1067174,18),(401,'Ricard','Puig Marti',19,959391,1),(402,'Jean-Clair','Todibo',19,959391,1),(403,'Emerson','Leite De Souza',20,959391,3),(404,'Lluis','Lopez Marmol',22,959391,20),(405,'Moussa','Wague',20,959391,1),(406,'Leonardo','Suarez',23,959391,9),(407,'Martin','Valjent',23,959391,18),(408,'Jose','Carlos Lazo Romero',23,959391,10),(409,'Rui','Tiago Dantas da Silva',25,959391,4),(410,'Jordi','Calavera Espinach',23,959391,16),(411,'Lumor','Agbenyenu',22,959391,18),(412,'Esteban','Rodrigo Burgos',27,959391,16),(413,'Cristian','Ganea',27,959391,11),(414,'Antonio','Jesus Regal Angulo',31,959391,15),(415,'Rodrigo','Rios Lozano',29,959391,4),(416,'Jiu Bao ','Jian Ying ',18,862493,5),(417,'An Bu ','Yu Kui ',20,862493,1),(418,'Ludovit','Reis',19,862493,1),(419,'Rodrigo','Tarin Higon',22,862493,19),(420,'Vasyl','Kravets',21,862493,19),(421,'Wilfrid','Kaptoum',22,862493,3),(422,'Joan','Sastre Vanrell',22,862493,18),(423,'Filip','Manojlovic',23,862493,10),(424,'Asier','Villalibre Molina',21,862493,11),(425,'Andoni','Gorosabel Espinosa',22,862493,7),(426,'Jose','Manuel Arnaiz Diaz',24,862493,19),(427,'Bernardo','Victor Cruz Torres',25,862493,4),(428,'Unai','Garcia Lugea',26,862493,12),(429,'Rafael','Jesus Navarro Mazuelos',25,862493,14),(430,'Aleksandar','Trajkovski',26,862493,18),(431,'Abdon','Prats Bastidas',26,862493,18),(432,'Luis','Jesus Rioja Gonzalez',25,862493,14),(433,'Ruben','Ivan Martinez Andrade',35,862493,12),(434,'Javier','Moyano Lujano',33,862493,15),(435,'Manuel','Reina Rodriguez',34,862493,18),(436,'Aridane','Hernandez Umpierrez',30,862493,12),(437,'Aridai','Cabrera Suarez',30,862493,18),(438,'Oihan','Sancet Tirapu',19,775382,11),(439,'Javier','Hernandez Carrera',21,775382,5),(440,'Stiven','Plaza',20,775382,15),(441,'Javier','Sanchez de Felipe',22,775382,15),(442,'Jeando','Fuchs',21,775382,14),(443,'Robin','Le Normand',22,775382,7),(444,'Yan','Brice Eteki',21,775382,4),(445,'Alejandro','Pozo Pozo',20,775382,8),(446,'Ander','Guevara Lajo',21,775382,7),(447,'Daniel','Martin Fernandez',20,775382,3),(448,'Emmanuel','Apeh',22,775382,17),(449,'Federico','Varela',23,775382,19),(450,'Alvaro','Aguado Mendez',23,775382,15),(451,'Iddrisu','Baba Mohammed',23,775382,18),(452,'Xavier','Quintilla Guasch',22,775382,9),(453,'Juan','Soriano Oropesa',21,775382,19),(454,'Enrique','Barja Afonso',22,775382,12),(455,'Javier','Munoz Jimenez',24,775382,14),(456,'Juan','Jose Narvaez',24,775382,3),(457,'David','Garcia Zubiria',25,775382,12),(458,'Jose','Antonio Martinez Gil',26,775382,4),(459,'Roberto','Antonio Correa Silva',26,775382,16),(460,'Kenan','Kodro',25,775382,11),(461,'Josep','Sene Escudero',27,775382,18),(462,'Marc','Pedraza Sarto',32,775382,18),(463,'Joaquin','Marin Ruiz',29,775382,4),(464,'Armando','Sadiku',28,775382,13),(465,'Francisco','Gamez Lopez',27,775382,18),(466,'Francisco','Montero Rubio',20,697069,2),(467,'Abel','Ruiz Ortega',19,697069,1),(468,'Mohammed','Salisu',20,697069,15),(469,'Modibo','Sagnan',20,697069,7),(470,'Gaizka','Larrazabal',21,697069,11),(471,'Gorka','Guruzeta Rodriguez',22,697069,11),(472,'Pervis','Josue Estupinan Tenorio',21,697069,12),(473,'Yangel','Herrera',21,697069,4),(474,'Jorge','de Frutos Sebastian',22,697069,15),(475,'Ivan','Saponjic',21,697069,2),(476,'Aitor','Ruibal Garcia',23,697069,19),(477,'Yaw','Yeboah',22,697069,17),(478,'Francisco','Jesus Crespo Garcia',22,697069,8),(479,'Gonzalo','Avila Gordon',21,697069,20),(480,'Salvador','Ruiz Rodriguez',24,697069,6),(481,'Neyder','Lozano',25,697069,4),(482,'Kevin','Vazquez Comesana',26,697069,17),(483,'Fernando','Garcia Puchades',25,697069,14),(484,'Francisco','Javier Campos Coll',37,697069,18),(485,'Manuel','Castellano Castro',30,697069,12),(486,'Luis','Miguel Sanchez Benitez',27,697069,15),(487,'Oriol','Busquets Mas',20,626666,1),(488,'Carles','Perez Sayol',21,626666,1),(489,'Juan','Miranda Gonzalez',19,626666,1),(490,'Hugo','Duro Perales',19,626666,10),(491,'Diego','Alende Lopez',21,626666,15),(492,'Ander','Barrenetxea',17,626666,7),(493,'Moctar','El Hacen',21,626666,15),(494,'Ermedin','Demirovic',21,626666,14),(495,'Victor','Campuzano Bonilla',22,626666,20),(496,'Cristian','Rivero Sabater',21,626666,6),(497,'Christopher','Ramos de la Flor',22,626666,15),(498,'Andoni','Zubiaurre Dorronsoro',22,626666,7),(499,'Ivan','Villar Martinez',21,626666,17),(500,'Eneko','Capilla Gonzalez',24,626666,7),(501,'Miquel','Parera Piza',23,626666,18),(502,'Ruben','Yanez Alabart',25,626666,10),(503,'Andres','Tomas Prieto Albert',25,626666,20),(504,'Ruben','Lobato Cabal',25,626666,16),(505,'Miguel','De la Fuente Escudero',19,563373,15),(506,'Sergio','Lopez Galache',20,563373,5),(507,'Roberto','Gonzalez Bayon',18,563373,3),(508,'Victor','Garcia Raja',22,563373,15),(509,'Jose','Luis Zalazar Martinez',21,563373,15),(510,'Merveille','Ndockyt',20,563373,10),(511,'Alvaro','Fidalgo Fernandez',22,563373,5),(512,'Ramiro','Guerra',22,563373,9),(513,'Arturo','Molina Tornero',23,563373,13),(514,'Olivier','Verdon',23,563373,14),(515,'Carlos','Neva Tey',23,563373,4),(516,'Juan','Hernandez Garcia',24,563373,17),(517,'Victor','Mollejo Carpintero',18,506473,2),(518,'Sergio','Camello Perez',18,506473,2),(519,'Juan','Brandariz Movilla',20,506473,1),(520,'Borja','Garces Moreno',19,506473,2),(521,'Adrian','de la Fuente',20,506473,5),(522,'Bryan','Gil Salvatierra',18,506473,8),(523,'Jose','Alejandro Martin Valeron',21,506473,19),(524,'Alex','Collado Gutierrez',20,506473,1),(525,'Jordi','Escobar Fernandez',17,506473,6),(526,'Juan','Berrocal Gonzalez',19,506473,8),(527,'Jorge','Cuenca Barreno',19,506473,1),(528,'Luis','Perea Hernandez',21,506473,12),(529,'Andre','Grandi',22,506473,19),(530,'Javier','Diaz Sanchez',22,506473,8),(531,'Josua','Mejias',21,506473,2),(532,'Francisco','Lopez Manzanara',22,506473,13),(533,'Samuel','Perez Farina',22,506473,15),(534,'Javier','Aviles Cortes',21,506473,19),(535,'Jon','Moncayola Tollar',21,506473,12),(536,'Yacoub','Aly Abeid',21,506473,13),(537,'Aaron','Escandell',23,506473,4),(538,'Carlos','Blanco Moreno',23,506473,9),(539,'Juan','Manuel Sanabria',19,455320,2),(540,'Ignacio','Pena Sotorres',20,455320,1),(541,'Iker','Losada Aragunde',17,455320,17),(542,'Alberto','Rodriguez Baro',21,455320,14),(543,'Jesus','Areso Blanco',19,455320,11),(544,'Jose','Alonso Alonso Lara',19,455320,8),(545,'Antonio','Moya Vega',21,455320,2),(546,'Jaime','Sierra Mateos',21,455320,19),(547,'Daniel','Vivian Moreno',19,455320,11),(548,'Victor','Lopez Ibanez',22,455320,14),(549,'Carlos','Isaac Munoz Obejero',21,455320,2),(550,'Andrei','Lupu',21,455320,14),(551,'Zourdine','Thior',21,455320,7),(552,'Paulino','de la Fuente Gomez',22,455320,14),(553,'Daniel','Molina Orta',23,455320,17),(554,'Adrian','Lopez Garrote',20,455320,20),(555,'David','Alba Fernandez',20,455320,10),(556,'Antonio','Perera Calderon',22,455320,14),(557,'Miguel','Mari Sanchez',22,455320,16),(558,'Yassin','Fekir',22,455320,3),(559,'Facundo','Garcia',19,455320,19),(560,'Javier','Jimenez Garcia',22,455320,6),(561,'Sofian','Chakla',25,455320,9),(562,'Eduardo','David Espiau Hernandez',24,455320,9),(563,'Roberto','Lopez Alcaide',19,409333,7),(564,'Unai','Vencedor Paris',18,409333,11),(565,'Rodrigo','Riquelme Reche',19,409333,2),(566,'Antonio','Islam Otegui Khalifi',21,409333,12),(567,'Alejandro','Dominguez Romero',20,409333,14),(568,'Victor','Gomez Perea',19,409333,20),(569,'Sergio','Lozano Lluch',20,409333,9),(570,'Mohamed','Ezzarfani',21,409333,20),(571,'Jon','Sillero Monreal',21,409333,11),(572,'Joan','Monterde Raygal',21,409333,13),(573,'Jokin','Ezkieta Mendiburu',22,409333,11),(574,'Juan','Manuel Perez Ruiz',22,409333,12),(575,'Daniel','Cardenas Lindez',22,409333,13),(576,'Jose','Mena Rodriguez',21,409333,8),(577,'Jose','Castano Munoz',20,409333,9),(578,'Pierre','Cornud',22,409333,18),(579,'Julen','Lopez Salas',23,409333,16),(580,'Luis','Garcia',21,409333,8),(581,'Gabriel','Salazar Rojo',23,409333,19),(582,'Francisco','Barbosa Vieites',20,409333,17),(583,'Alejandro','Corredera Alardi',23,409333,6),(584,'Endika','Irigoyen Bravo',22,409333,12),(585,'Salomon','Asumo Obama Ondo',19,367991,17),(586,'Diego','Altube Suarez',19,367991,5),(587,'Nicolas','Melamed Ribaudo',18,367991,20),(588,'Pol','Lozano Vizuete',19,367991,20),(589,'Fernando','Nino Rodriguez',18,367991,9),(590,'Daniel','Sandoval Fernandez',21,367991,13),(591,'Ivan','Martin Nunez',20,367991,9),(592,'Andrei','Ratiu',21,367991,9),(593,'Owusu','Kwabena',22,367991,19),(594,'Angel','Lopez Perez',22,367991,16),(595,'Ivan','Navarro Mateos',22,367991,3),(596,'Edgar','Gonzalez Estrada',22,367991,3),(597,'Juan','David Victoria Lopez',23,367991,4),(598,'Francisco','Jose Serrano Santos',24,367991,4),(599,'Isaac','Gomez Sanchez',23,367991,4),(600,'Andres','Pascual Santonja',22,367991,6),(601,'Jordi','Sanchez Ribas',24,367991,6),(602,'Diego','Varela Pampin',19,330824,17),(603,'Aitor','Lorea Vergara',21,330824,12),(604,'Sergio','Carreira Vilarino',18,330824,17),(605,'Alejandro','Dos Santos Ferreira',20,330824,2),(606,'Sergio','Bermejo Lillo',21,330824,17),(607,'Eliseo','Falcon Falcon',22,330824,13),(608,'Hodei','Oleaga Alarcia',22,330824,11),(609,'Juan','Carlos Lazaro Cervera',23,330824,16),(610,'Iago','Indias Fernandez',23,330824,20),(611,'Sergio','Duenas Ruiz',26,330824,18),(612,'Victor','De Baunbag',18,297411,18),(613,'Nais','Djouahra',19,297411,7),(614,'Elias','Ramirez Garcia',20,297411,18),(615,'Ismael','Gutierrez Montilla',18,297411,3),(616,'Daniel','Rebollo Franco',19,297411,3),(617,'Pablo','Lombo Suarez',20,297411,19),(618,'Angel','Sanchez Baro',21,297411,20),(619,'Ruben','Sanchez Perez',24,297411,4),(620,'Raul','Sanchez Sanchez',21,267373,19),(621,'Diego','Altamirano',22,267373,3),(622,'Julio','Alonso Sosa',20,267373,3),(623,'Raul','Prada Lozano',18,240368,18),(624,'Joaquin','Blazquez',19,240368,6),(625,'Dario','Ramos Pinazo',19,240368,10),(626,'Martin','Zubimendi Ibanez',20,216091,7),(627,'Ivan','Martinez Marques',17,157007,12);
/*!40000 ALTER TABLE `Players` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Positions`
--

DROP TABLE IF EXISTS `Positions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Positions` (
  `PositionID` int(11) NOT NULL AUTO_INCREMENT,
  `PositionName` varchar(30) NOT NULL,
  PRIMARY KEY (`PositionID`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Positions`
--

LOCK TABLES `Positions` WRITE;
/*!40000 ALTER TABLE `Positions` DISABLE KEYS */;
INSERT INTO `Positions` VALUES (1,'CAM'),(2,'CB'),(3,'CDM'),(4,'CF'),(5,'CM'),(6,'GK'),(7,'LB'),(8,'LM'),(9,'LW'),(10,'LWB'),(11,'RB'),(12,'RM'),(13,'RW'),(14,'RWB'),(15,'ST');
/*!40000 ALTER TABLE `Positions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Requests`
--

DROP TABLE IF EXISTS `Requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Requests` (
  `RequestID` int(11) NOT NULL AUTO_INCREMENT,
  `From` int(11) NOT NULL,
  `To` int(11) NOT NULL,
  `PlayerID` int(11) NOT NULL,
  `TransferFee` int(11) NOT NULL,
  `NewSalary` int(11) NOT NULL,
  `DateOfRequest` date NOT NULL,
  `PackageID` varchar(40) NOT NULL,
  PRIMARY KEY (`RequestID`),
  KEY `fk_Requests_Players1_idx` (`PlayerID`),
  KEY `fk_Requests_Clubs1_idx` (`To`),
  KEY `fk_Requests_Clubs2_idx` (`From`),
  KEY `fk_Requests_Packages1_idx` (`PackageID`),
  CONSTRAINT `fk_Requests_Clubs_FROM` FOREIGN KEY (`From`) REFERENCES `Clubs` (`ClubID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_Requests_Clubs_TO` FOREIGN KEY (`To`) REFERENCES `Clubs` (`ClubID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_Requests_Packages1` FOREIGN KEY (`PackageID`) REFERENCES `Packages` (`PackageID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_Requests_Players1` FOREIGN KEY (`PlayerID`) REFERENCES `Players` (`PlayerID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Requests`
--

LOCK TABLES `Requests` WRITE;
/*!40000 ALTER TABLE `Requests` DISABLE KEYS */;
INSERT INTO `Requests` VALUES (1,1,2,8,20000,1000000,'2020-06-01','fa1b5f90-a423-11ea-b433-ddd3c3c829df'),(2,2,1,24,20000,1000000,'2020-06-01','fa1b5f90-a423-11ea-b433-ddd3c3c829df'),(3,2,1,8,10000,6520969,'2020-06-01','8d36d3e0-a424-11ea-b433-ddd3c3c829df'),(4,1,2,24,10000,4259444,'2020-06-01','8d36d3e0-a424-11ea-b433-ddd3c3c829df'),(5,2,1,2,5000,200000,'2020-06-01','04b8cda0-a43a-11ea-93fc-9571883f98ab'),(6,1,2,8,50000,20000,'2020-06-01','04b8cda0-a43a-11ea-93fc-9571883f98ab');
/*!40000 ALTER TABLE `Requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Signatures`
--

DROP TABLE IF EXISTS `Signatures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Signatures` (
  `PackageID` varchar(40) NOT NULL,
  `ClubID` int(11) NOT NULL,
  `Status` int(11) NOT NULL,
  PRIMARY KEY (`PackageID`,`ClubID`),
  KEY `fk_Signatures_Clubs1_idx` (`ClubID`),
  CONSTRAINT `fk_Signatures_Clubs1` FOREIGN KEY (`ClubID`) REFERENCES `Clubs` (`ClubID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_Signatures_Packages1` FOREIGN KEY (`PackageID`) REFERENCES `Packages` (`PackageID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Signatures`
--

LOCK TABLES `Signatures` WRITE;
/*!40000 ALTER TABLE `Signatures` DISABLE KEYS */;
INSERT INTO `Signatures` VALUES ('04b8cda0-a43a-11ea-93fc-9571883f98ab',1,1),('04b8cda0-a43a-11ea-93fc-9571883f98ab',2,1),('8d36d3e0-a424-11ea-b433-ddd3c3c829df',1,1),('8d36d3e0-a424-11ea-b433-ddd3c3c829df',2,1),('fa1b5f90-a423-11ea-b433-ddd3c3c829df',1,1),('fa1b5f90-a423-11ea-b433-ddd3c3c829df',2,1);
/*!40000 ALTER TABLE `Signatures` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Transfers`
--

DROP TABLE IF EXISTS `Transfers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Transfers` (
  `PackageID` varchar(40) NOT NULL,
  `DateSigned` date NOT NULL,
  PRIMARY KEY (`PackageID`),
  CONSTRAINT `fk_Transfers_Packages1` FOREIGN KEY (`PackageID`) REFERENCES `Packages` (`PackageID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Transfers`
--

LOCK TABLES `Transfers` WRITE;
/*!40000 ALTER TABLE `Transfers` DISABLE KEYS */;
INSERT INTO `Transfers` VALUES ('04b8cda0-a43a-11ea-93fc-9571883f98ab','2020-06-01'),('8d36d3e0-a424-11ea-b433-ddd3c3c829df','2020-06-01'),('fa1b5f90-a423-11ea-b433-ddd3c3c829df','2020-06-01');
/*!40000 ALTER TABLE `Transfers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'TransferMarkt_sp20'
--

--
-- Dumping routines for database 'TransferMarkt_sp20'
--
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-06-01 15:25:07
