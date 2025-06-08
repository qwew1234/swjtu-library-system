-- MySQL dump 10.13  Distrib 8.0.40, for Win64 (x86_64)
--
-- Host: localhost    Database: swjtu_library
-- ------------------------------------------------------
-- Server version	8.0.40

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

--
-- Table structure for table `book_category`
--

DROP TABLE IF EXISTS `book_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `book_category` (
  `isbn` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'ISBN号',
  `book_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '书名',
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '图书类别',
  `author` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '作者',
  `publisher` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '出版社',
  `publish_date` date DEFAULT NULL COMMENT '出版日期',
  `price` decimal(10,2) DEFAULT NULL COMMENT '价格',
  `intro` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci COMMENT '图书简介',
  `total_quantity` int NOT NULL DEFAULT '0' COMMENT '馆藏总数',
  `borrowable_quantity` int NOT NULL DEFAULT '0' COMMENT '可借阅数量',
  PRIMARY KEY (`isbn`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `book_category`
--

LOCK TABLES `book_category` WRITE;
/*!40000 ALTER TABLE `book_category` DISABLE KEYS */;
INSERT INTO `book_category` (`isbn`, `book_name`, `category`, `author`, `publisher`, `publish_date`, `price`, `intro`, `total_quantity`, `borrowable_quantity`) VALUES ('9787111633451','数据库系统概念','计算机/数据库','Abraham Silberschatz','机械工业出版社','2019-10-01',99.00,'数据库领域的经典教材，全面深入地介绍了数据库系统。',4,3),('9787115494871','Python编程：从入门到实践','计算机/编程语言','Eric Matthes','人民邮电出版社','2020-07-01',89.00,'非常适合Python初学者的入门书籍，包含大量实例和项目。',5,5),('9787302552942','深入理解计算机系统','计算机/体系结构','Randal E. Bryant','清华大学出版社','2020-05-01',139.00,'计算机科学的经典之作，帮助读者从程序员的视角理解计算机。',3,2),('9787532767246','三体','科幻/小说','刘慈欣','重庆出版社','2008-01-01',23.00,'中国科幻文学的里程碑之作，讲述了地球文明在宇宙中的兴衰历程。',6,5),('9787544270878','百年孤独','外国文学/小说','加西亚·马尔克斯','南海出版公司','2011-06-01',39.50,'魔幻现实主义文学的代表作，描绘了布恩迪亚家族七代人的传奇故事。',4,4);
/*!40000 ALTER TABLE `book_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `book_info`
--

DROP TABLE IF EXISTS `book_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `book_info` (
  `isbn` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'ISBN号，图书的唯一标识',
  `book_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '书名',
  `author` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '作者',
  `publisher` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '出版社',
  `price` decimal(10,2) DEFAULT NULL COMMENT '价格',
  `total_quantity` int NOT NULL DEFAULT '0' COMMENT '馆藏总数',
  `borrowable_quantity` int NOT NULL DEFAULT '0' COMMENT '当前可借阅数量',
  PRIMARY KEY (`isbn`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `book_info`
--

LOCK TABLES `book_info` WRITE;
/*!40000 ALTER TABLE `book_info` DISABLE KEYS */;
INSERT INTO `book_info` (`isbn`, `book_name`, `author`, `publisher`, `price`, `total_quantity`, `borrowable_quantity`) VALUES ('9787111633451','数据库系统概念','Abraham Silberschatz','机械工业出版社',99.00,5,5),('9787115494871','Python编程：从入门到实践','Eric Matthes','人民邮电出版社',89.00,10,10),('9787302552942','深入理解计算机系统','Randal E. Bryant','清华大学出版社',139.00,3,3);
/*!40000 ALTER TABLE `book_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `book_instance`
--

DROP TABLE IF EXISTS `book_instance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `book_instance` (
  `book_id` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '图书书号 (图书馆内唯一)',
  `isbn` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '关联的ISBN号',
  `is_borrowed` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否可借 (0:可借, 1:已借出)',
  PRIMARY KEY (`book_id`) USING BTREE,
  KEY `fk_instance_to_category` (`isbn`) USING BTREE,
  CONSTRAINT `fk_instance_to_category` FOREIGN KEY (`isbn`) REFERENCES `book_category` (`isbn`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `book_instance`
--

LOCK TABLES `book_instance` WRITE;
/*!40000 ALTER TABLE `book_instance` DISABLE KEYS */;
INSERT INTO `book_instance` (`book_id`, `isbn`, `is_borrowed`) VALUES ('I247-001','9787532767246',1),('I247-002','9787532767246',0),('I247-003','9787532767246',0),('I247-004','9787532767246',0),('I247-005','9787532767246',0),('I247-006','9787532767246',0),('I712-001','9787544270878',0),('I712-002','9787544270878',0),('I712-003','9787544270878',0),('I712-004','9787544270878',0),('TP30-001','9787302552942',1),('TP30-002','9787302552942',0),('TP30-003','9787302552942',0),('TP311-001','9787111633451',1),('TP311-002','9787111633451',0),('TP311-003','9787111633451',0),('TP311-004','9787111633451',0),('TP312-001','9787115494871',0),('TP312-002','9787115494871',0),('TP312-003','9787115494871',0),('TP312-004','9787115494871',0),('TP312-005','9787115494871',0);
/*!40000 ALTER TABLE `book_instance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `borrow_records`
--

DROP TABLE IF EXISTS `borrow_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `borrow_records` (
  `record_id` int NOT NULL AUTO_INCREMENT,
  `book_id` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '借阅的实体书号',
  `reader_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '读者ID',
  `borrow_date` datetime NOT NULL COMMENT '借出日期',
  `return_date` datetime DEFAULT NULL COMMENT '归还日期 (NULL表示未还)',
  `due_date` datetime NOT NULL COMMENT '应归还日期',
  PRIMARY KEY (`record_id`) USING BTREE,
  KEY `fk_borrow_instance` (`book_id`) USING BTREE,
  KEY `fk_borrow_reader` (`reader_id`) USING BTREE,
  CONSTRAINT `fk_borrow_instance` FOREIGN KEY (`book_id`) REFERENCES `book_instance` (`book_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_borrow_reader_pro` FOREIGN KEY (`reader_id`) REFERENCES `readers` (`reader_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `borrow_records`
--

LOCK TABLES `borrow_records` WRITE;
/*!40000 ALTER TABLE `borrow_records` DISABLE KEYS */;
INSERT INTO `borrow_records` (`record_id`, `book_id`, `reader_id`, `borrow_date`, `return_date`, `due_date`) VALUES (4,'TP311-001','20210001','2025-05-10 10:00:00',NULL,'2025-06-09 10:00:00'),(5,'I247-001','20220002','2025-05-20 14:30:00',NULL,'2025-06-19 14:30:00'),(6,'TP30-001','teacher001','2025-06-01 09:00:00',NULL,'2025-07-01 09:00:00');
/*!40000 ALTER TABLE `borrow_records` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_borrow_pro` AFTER INSERT ON `borrow_records` FOR EACH ROW BEGIN
    -- 1. 更新图书实体表，标记为已借出
    UPDATE book_instance SET is_borrowed = 1 WHERE book_id = NEW.book_id;
    -- 2. 更新图书类别表，可借阅数-1
    UPDATE book_category SET borrowable_quantity = borrowable_quantity - 1 WHERE isbn = (SELECT isbn FROM book_instance WHERE book_id = NEW.book_id);
    -- 3. 更新读者表，已借数量+1
    UPDATE readers SET borrowed_quantity = borrowed_quantity + 1 WHERE reader_id = NEW.reader_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_return_pro` AFTER UPDATE ON `borrow_records` FOR EACH ROW BEGIN
    IF OLD.return_date IS NULL AND NEW.return_date IS NOT NULL THEN
        -- 1. 更新图书实体表，标记为可借
        UPDATE book_instance SET is_borrowed = 0 WHERE book_id = NEW.book_id;
        -- 2. 更新图书类别表，可借阅数+1
        UPDATE book_category SET borrowable_quantity = borrowable_quantity + 1 WHERE isbn = (SELECT isbn FROM book_instance WHERE book_id = NEW.book_id);
        -- 3. 更新读者表，已借数量-1
        UPDATE readers SET borrowed_quantity = borrowed_quantity - 1 WHERE reader_id = NEW.reader_id;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary view structure for view `overdue_records`
--

DROP TABLE IF EXISTS `overdue_records`;
/*!50001 DROP VIEW IF EXISTS `overdue_records`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `overdue_records` AS SELECT 
 1 AS `record_id`,
 1 AS `isbn`,
 1 AS `book_name`,
 1 AS `reader_id`,
 1 AS `reader_name`,
 1 AS `borrow_date`,
 1 AS `due_date`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `readers`
--

DROP TABLE IF EXISTS `readers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `readers` (
  `reader_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '借书证号/学号',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '姓名',
  `password` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '登录密码',
  `sex` enum('男','女') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '男',
  `birth_date` date DEFAULT NULL COMMENT '出生年月',
  `id_card` varchar(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '身份证号',
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '职称',
  `department` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '工作部门/院系',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '家庭住址',
  `telephone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '联系电话（用于登录）',
  `max_borrow_quantity` int NOT NULL DEFAULT '5' COMMENT '可借数量',
  `borrowed_quantity` int NOT NULL DEFAULT '0' COMMENT '已借数量',
  `role` int NOT NULL DEFAULT '0' COMMENT '角色 0:读者 1:管理员',
  PRIMARY KEY (`reader_id`) USING BTREE,
  UNIQUE KEY `telephone` (`telephone`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `readers`
--

LOCK TABLES `readers` WRITE;
/*!40000 ALTER TABLE `readers` DISABLE KEYS */;
INSERT INTO `readers` (`reader_id`, `name`, `password`, `sex`, `birth_date`, `id_card`, `title`, `department`, `address`, `telephone`, `max_borrow_quantity`, `borrowed_quantity`, `role`) VALUES ('20210001','张伟','123456','男','2003-05-10','51010320030510xxxx','学生','计算机科学与技术学院','犀浦校区X1宿舍','13811110001',5,1,0),('20220002','李静','123456','女','2004-08-22','51010320040822xxxx','学生','土木工程学院','犀浦校区X2宿舍','13811110002',5,1,0),('admin001','图书馆员赵','admin','女','1990-11-20','51010319901120xxxx','职员','图书馆','图书馆办公室','13888888888',20,0,1),('teacher001','王建国','123456','男','1985-03-15','51010319850315xxxx','教授','电气工程学院','九里校区综合楼A座','13811110003',10,1,0);
/*!40000 ALTER TABLE `readers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'swjtu_library'
--

--
-- Final view structure for view `overdue_records`
--

/*!50001 DROP VIEW IF EXISTS `overdue_records`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `overdue_records` AS select `br`.`record_id` AS `record_id`,`bi`.`isbn` AS `isbn`,`bc`.`book_name` AS `book_name`,`br`.`reader_id` AS `reader_id`,`r`.`name` AS `reader_name`,`br`.`borrow_date` AS `borrow_date`,`br`.`due_date` AS `due_date` from (((`borrow_records` `br` join `book_instance` `bi` on((`br`.`book_id` = `bi`.`book_id`))) join `book_category` `bc` on((`bi`.`isbn` = `bc`.`isbn`))) join `readers` `r` on((`br`.`reader_id` = `r`.`reader_id`))) where ((`br`.`return_date` is null) and (`br`.`due_date` < now())) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-06-07 18:13:00
