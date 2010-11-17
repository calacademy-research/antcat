-- MySQL dump 10.13  Distrib 5.1.46, for apple-darwin10.2.0 (i386)
--
-- Host: localhost    Database: antcat_development
-- ------------------------------------------------------
-- Server version	5.1.46-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `authors`
--

DROP TABLE IF EXISTS `authors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `authors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `verified` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `author_created_at_name` (`created_at`,`name`),
  KEY `author_name_idx` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=174187 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `authors`
--

LOCK TABLES `authors` WRITE;
/*!40000 ALTER TABLE `authors` DISABLE KEYS */;
INSERT INTO `authors` VALUES (170693,'Anonymous','2010-11-17 02:42:35','2010-11-17 02:42:35',1),(171026,'International Commission on Zoological Nomenclature','2010-11-17 02:44:32','2010-11-17 02:44:32',1),(171974,'Österreichischen Gesellschaft für Ameisenkunde','2010-11-17 02:51:14','2010-11-17 02:51:14',1),(174179,'Commissione Reale del Parco','2010-11-17 19:01:34','2010-11-17 19:01:34',1),(174180,'Zoological Survey of India, Director','2010-11-17 19:03:05','2010-11-17 19:03:05',1),(174181,'CSIRO','2010-11-17 19:03:21','2010-11-17 19:03:21',1),(174182,'Director, Zoological Survey of India','2010-11-17 19:04:28','2010-11-17 19:04:28',1),(174183,'Société de Naturalistes et d\'Agriculteurs','2010-11-17 19:05:51','2010-11-17 19:05:51',1),(174184,'Ier Congrès International d\'Entomologie, Bruxelles, août 1910','2010-11-17 19:07:38','2010-11-17 19:07:38',1),(174185,'Academy of Science Survey Team','2010-11-17 19:08:42','2010-11-17 19:08:42',1),(174186,'P. Jaisson','2010-11-17 19:09:11','2010-11-17 19:09:11',1);
/*!40000 ALTER TABLE `authors` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2010-11-17 11:27:38
