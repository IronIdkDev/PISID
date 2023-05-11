-- MariaDB dump 10.19  Distrib 10.4.28-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: pisid
-- ------------------------------------------------------
-- Server version	10.4.28-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `alerta`
--

DROP TABLE IF EXISTS `alerta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `alerta` (
  `IDAlerta` int(11) NOT NULL AUTO_INCREMENT,
  `Hora` timestamp NOT NULL DEFAULT current_timestamp(),
  `Sala` int(11) NOT NULL,
  `Sensor` int(11) NOT NULL,
  `Leitura` decimal(4,2) NOT NULL,
  `TipoAlerta` varchar(20) NOT NULL,
  `Mensagem` varchar(100) NOT NULL,
  `horaescrita` timestamp NOT NULL DEFAULT current_timestamp(),
  `IDExperiência` int(11) NOT NULL,
  PRIMARY KEY (`IDAlerta`),
  KEY `IDExperiência` (`IDExperiência`),
  CONSTRAINT `alerta_ibfk_1` FOREIGN KEY (`IDExperiência`) REFERENCES `experiencia` (`IDexperiência`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alerta`
--

LOCK TABLES `alerta` WRITE;
/*!40000 ALTER TABLE `alerta` DISABLE KEYS */;
INSERT INTO `alerta` VALUES (1,'2023-05-05 19:32:53',1,0,0.00,'VERMELHO','O limite de ratos de uma sala da experiência foi ultrapassado','2023-05-05 19:32:53',1),(2,'2023-05-05 19:37:51',2,0,0.00,'AMARELO','O limite de ratos de uma sala da experiência foi ultrapassado','2023-05-05 19:37:51',2),(3,'2023-05-05 19:37:58',2,0,0.00,'AMARELO','O limite de ratos de uma sala da experiência foi ultrapassado','2023-05-05 19:37:58',2),(4,'2023-05-05 19:38:40',2,0,0.00,'AMARELO','O limite de ratos de uma sala da experiência foi ultrapassado','2023-05-05 19:38:40',2),(5,'2023-05-05 19:38:46',2,0,0.00,'VERMELHO','O limite de ratos de uma sala da experiência foi ultrapassado','2023-05-05 19:38:46',2);
/*!40000 ALTER TABLE `alerta` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `experiencia`
--

DROP TABLE IF EXISTS `experiencia`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `experiencia` (
  `IDexperiência` int(11) NOT NULL AUTO_INCREMENT,
  `Descricao` text DEFAULT NULL,
  `Investigador` varchar(50) NOT NULL,
  `DataHora` timestamp NOT NULL DEFAULT current_timestamp(),
  `NumeroRatos` int(11) NOT NULL,
  `LimiteRatosSala` int(11) NOT NULL,
  `SegundosSemMovimento` int(11) NOT NULL,
  `TemperaturaIdeal` decimal(4,2) NOT NULL,
  `VariacaoTemperaturaMaxima` decimal(4,2) NOT NULL,
  `Ativa` int(1) NOT NULL,
  PRIMARY KEY (`IDexperiência`),
  KEY `Investigador` (`Investigador`),
  CONSTRAINT `experiencia_ibfk_1` FOREIGN KEY (`Investigador`) REFERENCES `utilizador` (`EmailUtilizador`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experiencia`
--

LOCK TABLES `experiencia` WRITE;
/*!40000 ALTER TABLE `experiencia` DISABLE KEYS */;
INSERT INTO `experiencia` VALUES (0,'Experiência default. Recebe dados que não pertencem a nenhuma experiência','default','2023-05-02 13:06:04',0,0,0,0.00,0.00,0),(1,'Experiencia teste','bruno@gmail.com','2023-05-05 19:26:57',8,2,45,20.00,3.00,-1),(2,'Experiencia Nº 11','bruno@gmail.com','2023-05-05 19:36:56',12,2,67,23.00,3.00,-1);
/*!40000 ALTER TABLE `experiencia` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `verificaUser` BEFORE INSERT ON `experiencia` FOR EACH ROW BEGIN

  DECLARE count INT;

  

  IF NOT EXISTS(SELECT 1 FROM utilizador WHERE utilizador.EmailUtilizador = NEW.Investigador AND utilizador.TipoUtilizador = 'INV' AND utilizador.Ativo = 1 ) THEN

    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O User não pode criar experiências';

  END IF;

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
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `contaExperiencia` AFTER INSERT ON `experiencia` FOR EACH ROW BEGIN

  DECLARE experiencias INT;



  SELECT NúmeroExperiências INTO experiencias 

  FROM utilizador

  WHERE EmailUtilizador = NEW.Investigador;



  UPDATE utilizador

  SET NúmeroExperiências = experiencias + 1

  WHERE EmailUtilizador = NEW.Investigador;

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
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `add_Salas` AFTER INSERT ON `experiencia` FOR EACH ROW BEGIN



DECLARE i INT;

DECLARE j INT;

DECLARE counter INT;

SET j = 10;

SET i = 1;

SET counter = new.NumeroRatos;



WHILE (i <= j )DO



IF(i = 1)THEN

	INSERT INTO medicoessalas (IDExperiencia, NumeroRatosFinal,Sala) 

    VALUES (new.IDExperiência, new.NumeroRatos, i);

    ELSE

	INSERT INTO medicoessalas (IDExperiencia, NumeroRatosFinal,Sala) 

    VALUES (new.IDExperiência, 0, i);

    END IF;

    SET i = i + 1;

END WHILE;









END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `medicoespassagens`
--

DROP TABLE IF EXISTS `medicoespassagens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `medicoespassagens` (
  `IdMedicao` int(11) NOT NULL AUTO_INCREMENT,
  `Hora` timestamp NOT NULL DEFAULT current_timestamp(),
  `SalaEntrada` int(11) NOT NULL,
  `SalaSaida` int(11) NOT NULL,
  `IDExperiência` int(11) NOT NULL,
  PRIMARY KEY (`IdMedicao`),
  KEY `IDExperiência` (`IDExperiência`) USING BTREE,
  CONSTRAINT `medicoespassagens_ibfk_1` FOREIGN KEY (`IDExperiência`) REFERENCES `experiencia` (`IDexperiência`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medicoespassagens`
--

LOCK TABLES `medicoespassagens` WRITE;
/*!40000 ALTER TABLE `medicoespassagens` DISABLE KEYS */;
INSERT INTO `medicoespassagens` VALUES (1,'2023-05-04 12:25:59',2,1,0),(2,'2023-05-04 13:25:59',2,1,0),(3,'2023-05-04 13:25:59',0,0,0),(4,'2023-05-04 13:25:59',0,0,1),(5,'0000-00-00 00:00:00',2,1,1),(6,'0000-00-00 00:00:00',2,1,0),(7,'2023-05-04 12:25:59',2,1,0),(8,'2023-05-04 12:25:59',2,1,0),(9,'2023-05-04 13:25:59',0,0,2),(10,'2023-05-04 13:25:59',2,1,2),(11,'2023-05-04 13:25:59',2,1,2),(12,'2023-05-04 13:25:59',2,1,2),(13,'2023-05-04 13:25:59',2,1,2),(14,'2023-05-04 13:25:59',2,1,2),(15,'2023-05-04 13:25:59',2,1,0);
/*!40000 ALTER TABLE `medicoespassagens` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `VerificaPassagemRatos` BEFORE INSERT ON `medicoespassagens` FOR EACH ROW BEGIN



DECLARE number INT;



SELECT medicoessalas.NumeroRatosFinal INTO number

FROM medicoessalas

WHERE medicoessalas.Sala = new.SalaSaida

AND medicoessalas.IDExperiencia = new.IDExperiência;



IF(number = 0)THEN



    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não é possível adicionar esta passagem'; 

    

    END IF;









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
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `passagemRatos` AFTER INSERT ON `medicoespassagens` FOR EACH ROW BEGIN 



DECLARE count INT; 



DECLARE counter INT; 



  



SET count = (SELECT NumeroRatosFinal FROM medicoessalas WHERE Sala = new.SalaEntrada 

             AND medicoessalas.IDExperiencia = new.IDExperiência); 



SET counter = (SELECT NumeroRatosFinal FROM medicoessalas WHERE Sala = new.SalaSaida

              AND medicoessalas.IDExperiencia = new.IDExperiência); 



  



UPDATE medicoessalas SET NumeroRatosFinal = count + 1 WHERE Sala = new.SalaEntrada AND medicoessalas.IDExperiencia = new.IDExperiência; 



UPDATE medicoessalas SET NumeroRatosFinal = counter - 1 WHERE Sala = new.SalaSaida AND medicoessalas.IDExperiencia 

= new.IDExperiência; 



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
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `Ativa_Experiencia` AFTER INSERT ON `medicoespassagens` FOR EACH ROW BEGIN



DECLARE counter INT;

DECLARE id INT;



SELECT COUNT(*) INTO counter

FROM experiencia

WHERE experiencia.Ativa = 2;





IF( new.SalaSaida = 0 AND new.SalaEntrada = 0)THEN



	IF(counter = 0)THEN

    

		SELECT experiencia.IDexperiência INTO id 

		FROM experiencia 

		WHERE Ativa = 1 

		ORDER BY DataHora LIMIT 1;



		UPDATE experiencia set experiencia.Ativa = 2

		WHERE experiencia.IDexperiência = id;

        

	ELSE 

    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dado não adicionado';



END IF;



END IF;











END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `medicoessalas`
--

DROP TABLE IF EXISTS `medicoessalas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `medicoessalas` (
  `IDExperiencia` int(11) NOT NULL,
  `NumeroRatosFinal` int(11) NOT NULL,
  `Sala` int(11) NOT NULL,
  PRIMARY KEY (`IDExperiencia`,`Sala`),
  KEY `Sala` (`Sala`),
  CONSTRAINT `medicoessalas_ibfk_1` FOREIGN KEY (`IDExperiencia`) REFERENCES `experiencia` (`IDexperiência`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medicoessalas`
--

LOCK TABLES `medicoessalas` WRITE;
/*!40000 ALTER TABLE `medicoessalas` DISABLE KEYS */;
INSERT INTO `medicoessalas` VALUES (1,7,1),(1,1,2),(1,0,3),(1,0,4),(1,0,5),(1,0,6),(1,0,7),(1,0,8),(1,0,9),(1,0,10),(2,7,1),(2,5,2),(2,0,3),(2,0,4),(2,0,5),(2,0,6),(2,0,7),(2,0,8),(2,0,9),(2,0,10);
/*!40000 ALTER TABLE `medicoessalas` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `verificaUpdateRatos` AFTER UPDATE ON `medicoessalas` FOR EACH ROW BEGIN



DECLARE count INT;

DECLARE id INT;

DECLARE sala int;

DECLARE ratosSala INT;

DECLARE descricao TEXT;



SET sala = new.Sala;

SET id = new.IDExperiencia;



SELECT experiencia.LimiteRatosSala INTO ratosSala

FROM experiencia

WHERE experiencia.IDexperiência = id; 





IF(new.NumeroRatosFinal > ratosSala AND sala <> 1)THEN

	SELECT COUNT(*) INTO count FROM alerta;

    

    IF(new.NumeroRatosFinal - ratosSala < 3)THEN

    INSERT INTO alerta (IDAlerta, Hora, Sala, TipoAlerta,Mensagem,horaescrita,IDExperiência)

	VALUES (count +1, current_timestamp(),  sala, 'AMARELO','O limite de ratos de uma sala da experiência foi ultrapassado',current_timestamp(), id );  

	

    ELSE

    

	INSERT INTO alerta (IDAlerta, Hora, Sala, TipoAlerta,Mensagem,horaescrita,IDExperiência)

	VALUES (count +1, current_timestamp(),  sala, 'VERMELHO','O limite de ratos de uma sala da experiência foi ultrapassado',current_timestamp(), id );  

    

    UPDATE experiencia SET experiencia.Ativa = -1 

    WHERE experiencia.IDexperiência = id;

    

    

END IF;

end if;



END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `medicoestemperatura`
--

DROP TABLE IF EXISTS `medicoestemperatura`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `medicoestemperatura` (
  `IDMedicao` int(11) NOT NULL AUTO_INCREMENT,
  `Hora` timestamp NULL DEFAULT current_timestamp(),
  `Leitura` decimal(4,2) NOT NULL,
  `Sensor` int(11) NOT NULL,
  `IDExperiência` int(11) NOT NULL,
  `Outlier` tinyint(4) NOT NULL,
  PRIMARY KEY (`IDMedicao`),
  KEY `IDExperiência` (`IDExperiência`),
  CONSTRAINT `medicoestemperatura_ibfk_1` FOREIGN KEY (`IDExperiência`) REFERENCES `experiencia` (`IDexperiência`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medicoestemperatura`
--

LOCK TABLES `medicoestemperatura` WRITE;
/*!40000 ALTER TABLE `medicoestemperatura` DISABLE KEYS */;
INSERT INTO `medicoestemperatura` VALUES (1,'2023-05-04 13:25:59',9.00,2,0,0);
/*!40000 ALTER TABLE `medicoestemperatura` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `criarAlertaTemp` AFTER INSERT ON `medicoestemperatura` FOR EACH ROW BEGIN



DECLARE tempIdeal DECIMAL;

DECLARE variacaoTemp DECIMAL;

DECLARE tempSub DECIMAL;

DECLARE tempUlt DECIMAL;

DECLARE media DECIMAL;

DECLARE id INT;

DECLARE count INT;



SELECT experiencia.IDexperiência INTO id

FROM experiencia

WHERE experiencia.Ativa = 1 AND experiencia.IDexperiência = new.IDExperiência;



SELECT experiencia.TemperaturaIdeal INTO tempIdeal

FROM experiencia

WHERE experiencia.IDexperiência = new.IDExperiência;



SELECT experiencia.VariacaoTemperaturaMaxima INTO variacaoTemp

FROM experiencia

WHERE experiencia.IDexperiência = new.IDExperiência;



SET tempSub = tempIdeal - variacaoTemp;

SET tempUlt = tempIdeal + variacaoTemp;



SELECT AVG(Leitura) INTO media

FROM(

SELECT medicoestemperatura.Leitura

FROM medicoestemperatura

WHERE medicoestemperatura.IDExperiência = id AND medicoestemperatura.Outlier = 0

ORDER BY medicoestemperatura.Hora DESC

LIMIT 3

) AS ultimas_medicoes;



IF (media < tempSub OR media > tempUlt) THEN

SELECT COUNT(*) INTO count FROM alerta;

INSERT INTO alerta (IDAlerta, Hora, Sensor, Leitura, TipoAlerta, Mensagem, horaescrita, IDExperiência)

VALUES (count + 1, current_timestamp(), new.Sensor, media, 'Alerta Temperatura', 'O intervalo de temperatura não foi verificado nas últimas 3 medições', current_timestamp(), id);

END IF;



END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `odoresexperiencia`
--

DROP TABLE IF EXISTS `odoresexperiencia`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `odoresexperiencia` (
  `Sala` int(11) NOT NULL,
  `IdExperiencia` int(11) NOT NULL,
  `CodigoOdor` varchar(5) NOT NULL,
  `IDMedicao` int(11) NOT NULL,
  PRIMARY KEY (`IDMedicao`),
  KEY `IdExperiencia` (`IdExperiencia`),
  CONSTRAINT `odoresexperiencia_ibfk_1` FOREIGN KEY (`IdExperiencia`) REFERENCES `experiencia` (`IDexperiência`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `odoresexperiencia`
--

LOCK TABLES `odoresexperiencia` WRITE;
/*!40000 ALTER TABLE `odoresexperiencia` DISABLE KEYS */;
/*!40000 ALTER TABLE `odoresexperiencia` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `verificaSalaExperiencia` BEFORE INSERT ON `odoresexperiencia` FOR EACH ROW BEGIN

  IF EXISTS(SELECT 1 FROM odoresexperiencia WHERE odoresexperiencia.Sala = NEW.Sala AND odoresexperiencia.IdExperiencia = NEW.IDExperiencia) THEN

    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Os valores já existem na tabela';

  END IF;

  IF EXISTS (SELECT 1

      FROM parâmetrosadicionais

      WHERE parâmetrosadicionais.IDExperiência = NEW.IDExperiencia AND parâmetrosadicionais.NúmeroSalas < NEW.Sala) THEN 

          SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Essa sala não existe';

  

  

  END IF;

  

  

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `parâmetrosadicionais`
--

DROP TABLE IF EXISTS `parâmetrosadicionais`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `parâmetrosadicionais` (
  `IDExperiência` int(11) NOT NULL,
  `NúmeroSalas` int(11) NOT NULL,
  PRIMARY KEY (`IDExperiência`),
  CONSTRAINT `IDExperiência` FOREIGN KEY (`IDExperiência`) REFERENCES `experiencia` (`IDexperiência`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `parâmetrosadicionais`
--

LOCK TABLES `parâmetrosadicionais` WRITE;
/*!40000 ALTER TABLE `parâmetrosadicionais` DISABLE KEYS */;
/*!40000 ALTER TABLE `parâmetrosadicionais` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `addSalas` AFTER INSERT ON `parâmetrosadicionais` FOR EACH ROW BEGIN



DECLARE i INT;

DECLARE j INT;



SET j = 10;

SET i = 1;



WHILE (i <= j )DO

	INSERT INTO medicoessalas (IDExperiencia, NumeroRatosFinal,Sala) 

    VALUES (new.IDExperiência, 0, i);

    SET i = i + 1;

END WHILE;









END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `substanciaexperiencia`
--

DROP TABLE IF EXISTS `substanciaexperiencia`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `substanciaexperiencia` (
  `NumeroRatos` int(11) NOT NULL,
  `CodigoSubstancia` varchar(5) NOT NULL,
  `IDexperiencia` int(11) NOT NULL,
  `IDMedicao` int(11) NOT NULL,
  PRIMARY KEY (`IDMedicao`),
  KEY `IDexperiencia` (`IDexperiencia`),
  CONSTRAINT `substanciaexperiencia_ibfk_1` FOREIGN KEY (`IDexperiencia`) REFERENCES `experiencia` (`IDexperiência`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `substanciaexperiencia`
--

LOCK TABLES `substanciaexperiencia` WRITE;
/*!40000 ALTER TABLE `substanciaexperiencia` DISABLE KEYS */;
/*!40000 ALTER TABLE `substanciaexperiencia` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `utilizador`
--

DROP TABLE IF EXISTS `utilizador`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `utilizador` (
  `NomeUtilizador` varchar(100) NOT NULL,
  `TelefoneUtilizador` varchar(12) NOT NULL,
  `TipoUtilizador` varchar(3) NOT NULL,
  `EmailUtilizador` varchar(50) NOT NULL,
  `Ativo` tinyint(1) NOT NULL,
  `NúmeroExperiências` int(4) NOT NULL,
  PRIMARY KEY (`EmailUtilizador`),
  UNIQUE KEY `TelefoneUtilizador` (`TelefoneUtilizador`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `utilizador`
--

LOCK TABLES `utilizador` WRITE;
/*!40000 ALTER TABLE `utilizador` DISABLE KEYS */;
INSERT INTO `utilizador` VALUES ('Alice','910349808','TEC','alice@gmail.com',1,0),('Bruno','999999999','INV','bruno@gmail.com',1,16),('Default','000000000','INV','default',1,1),('Vasco','910349086','ADM','vasquinho@iscte-iu.pt',1,0);
/*!40000 ALTER TABLE `utilizador` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-05-05 21:20:25
