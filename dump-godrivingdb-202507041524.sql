/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.7.2-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: godrivingdb
-- ------------------------------------------------------
-- Server version	11.7.2-MariaDB-ubu2404

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `blocked_schedules`
--

DROP TABLE IF EXISTS `blocked_schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `blocked_schedules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_instructor` int(11) NOT NULL,
  `date_start` datetime NOT NULL,
  `date_end` datetime NOT NULL,
  `reason` enum('ferias','exame','outro') NOT NULL,
  PRIMARY KEY (`id`),
  KEY `id_instructor` (`id_instructor`),
  CONSTRAINT `blocked_schedules_ibfk_1` FOREIGN KEY (`id_instructor`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blocked_schedules`
--

LOCK TABLES `blocked_schedules` WRITE;
/*!40000 ALTER TABLE `blocked_schedules` DISABLE KEYS */;
INSERT INTO `blocked_schedules` VALUES
(1,15,'2025-06-19 09:00:00','2025-06-20 19:00:00','ferias'),
(3,15,'2025-06-21 09:00:00','2025-06-21 11:00:00','exame'),
(4,15,'2025-07-02 09:00:00','2025-07-02 11:00:00','exame'),
(6,15,'2025-06-17 09:00:00','2025-06-17 12:00:00','exame'),
(7,15,'2025-06-16 09:00:00','2025-06-16 10:00:00','exame');
/*!40000 ALTER TABLE `blocked_schedules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `classes`
--

DROP TABLE IF EXISTS `classes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `classes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_student` int(11) NOT NULL,
  `id_instructor` int(11) NOT NULL,
  `time` datetime NOT NULL DEFAULT current_timestamp(),
  `class_status` enum('pendente','aceite','recusada','concluída') NOT NULL DEFAULT 'pendente',
  `nome_aluno` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id_student` (`id_student`),
  KEY `id_instructor` (`id_instructor`),
  CONSTRAINT `classes_ibfk_1` FOREIGN KEY (`id_student`) REFERENCES `user` (`id`),
  CONSTRAINT `classes_ibfk_2` FOREIGN KEY (`id_instructor`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `classes`
--

LOCK TABLES `classes` WRITE;
/*!40000 ALTER TABLE `classes` DISABLE KEYS */;
INSERT INTO `classes` VALUES
(28,19,18,'2025-06-16 11:00:00','pendente','aluno7'),
(29,20,15,'2025-06-16 11:00:00','aceite','aluno6'),
(34,22,15,'2025-06-16 12:00:00','concluída','aluno5');
/*!40000 ALTER TABLE `classes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `type`
--

DROP TABLE IF EXISTS `type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `type`
--

LOCK TABLES `type` WRITE;
/*!40000 ALTER TABLE `type` DISABLE KEYS */;
INSERT INTO `type` VALUES
(1,'Aluno'),
(2,'Instrutor'),
(3,'Recepcionista');
/*!40000 ALTER TABLE `type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `id_type` int(11) NOT NULL,
  `category` enum('A','B','C','D','E') DEFAULT NULL,
  `associated_car` varchar(50) DEFAULT NULL,
  `instructor` varchar(100) DEFAULT NULL,
  `first_login` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `id_type` (`id_type`),
  CONSTRAINT `user_ibfk_1` FOREIGN KEY (`id_type`) REFERENCES `type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES
(4,'Inês','ines@example.com','$2b$10$uk6RPb69/BMSq0iusHM/L.QdYd.2BRcszsWR6JzAaugIFfehpniRu',1,'B','Kia Rio',NULL,1),
(10,'Recepcionista Edite','edite@example.com','$2b$10$9Tdw6WzYrYeRZnemGBc8Zenqazlr.PJyIhzgL9MZDvsDhiqPIiFLu',3,NULL,NULL,NULL,1),
(11,'aluno2','aluno2@example.com','$2b$10$.AvXe9skw5Kz8qodYOW.Ju17flt64nLHB9CgboMfJph8oV0o9OzSC',1,'B',NULL,NULL,0),
(13,'aluno4','aluno4@example.com','$2b$10$JlSl1mu6348Vv4CtA2oH7u7o1aOiwQPiTWGAox2l8jZem4ezCJToe',1,NULL,NULL,'Sérgio',1),
(14,'aluno3','aluno3@example.com','$2b$10$e.ICnJWHh7BrLdbYS/W76uh0DR2VvhTibzAmJ9f3HNGkAww4UOSaS',1,'B',NULL,'Sérgio',1),
(15,'inst1','inst1@example.com','$2b$10$nuhQM9G8GlABnBXFw2KgIOdkrUfHkwd7d0TXzO6EuMNSpJ6nNxClG',2,NULL,NULL,NULL,0),
(16,'inst2','inst2@example.com','$2b$10$F3drUa3HZk/i3ALh4GWNkOG7ydm94EKm5bA5qG5lepe1G5UQRnbqq',2,NULL,NULL,NULL,1),
(17,'edite2','edite2@example.com','$2b$10$iauVQSLS6jIofYetfJaza.XeTkMNQQGgHEkhnqc6mxo2/Bc4MxmxG',3,NULL,NULL,NULL,1),
(18,'Pedro Gregório','pedrog@example.com','$2b$10$7SPW2bW1BCD9P9MShri.t.quYIRza5c.z833Lp/Z02RRnNQ58Wyp.',2,NULL,NULL,NULL,1),
(19,'aluno7','aluno7@example.com','$2b$10$DvG2ot9Di3bqPUAoSdUTqObswuWSjiuh.7fmfJFH9r.yuOp7PjRWe',1,'B',NULL,'Pedro Gregório',1),
(20,'aluno6','aluno6@example.com','$2b$10$ErK6WWsd1vT4PRmeek./JOpI0h8EVNdVR5Qk/NV1JnQblkloKoJ6a',1,'B',NULL,'inst1',1),
(22,'aluno5','aluno5@example.com','$2b$10$wK8X9ouP2VNKRdWt1B1dtupayB3Z/wQxyMCCoOac6cAf4zxlrkkhm',1,'B','Opel Corsa','inst1',1),
(23,'aluno8','aluno8@example.com','$2b$10$jp6Fc/pLMcOvumuRPd3iAuRDSeBfFvQxVW9KovXC29e/hVhPwmhGe',1,'B','Kia Rio','inst1',1);
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'godrivingdb'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2025-07-04 15:24:26
