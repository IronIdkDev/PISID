-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 30-Abr-2023 às 20:45
-- Versão do servidor: 10.4.28-MariaDB
-- versão do PHP: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `pisid`
--

DELIMITER $$
--
-- Procedimentos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `addSalas` (IN `nSalas` INT)   BEGIN
DECLARE id INT;

SELECT experiencia.IDexperiência INTO id
FROM experiencia
ORDER BY experiencia.IDexperiência DESC 
LIMIT 1;


INSERT INTO parâmetrosadicionais (IDExperiência, NúmeroSalas)
VALUES (id, nSalas);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AtualizaExperiencia` (IN `IDExperiencia` INT)   BEGIN

DECLARE ativo INT;
DECLARE count INT;
DECLARE counter INT;
SELECT Ativa INTO ativo FROM experiencia WHERE experiencia.IDexperiência = IDExperiencia;


IF ativo = 1 THEN
	UPDATE experiencia SET Ativa = 0 WHERE experiencia.IDexperiência = IDExperiencia;
    
    
    ELSE
    
    SELECT COUNT(*) INTO count FROM experiencia WHERE Ativa = 1;
    
	SELECT COUNT(*) INTO counter FROM medicoespassagens WHERE medicoespassagens.IDExperiência = IDExperiencia;

	IF (count > 0 OR counter > 0) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Já há uma experiência ativa ou esta experiência já aconteceu';
    ELSEIF (count = 0 AND counter =0) THEN
    	UPDATE experiencia SET experiencia.Ativa = 1 WHERE experiencia.IDexperiência = IDExperiencia;
    END IF;

END IF;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Criar_Experiencia` (IN `descricao` TEXT, IN `investigador` VARCHAR(50), IN `nratos` INT(11), IN `limitesRatos` INT(11), IN `segSemMovi` INT(11), IN `tempIdeal` DECIMAL(4,2), IN `variacaoMax` DECIMAL(4,2))   BEGIN

DECLARE count INT;

SELECT COUNT(*) INTO count FROM experiencia;

INSERT INTO experiencia (IDexperiência, Descricao, Investigador, DataHora, NumeroRatos,LimiteRatosSala, SegundosSemMovimento, TemperaturaIdeal, VariacaoTemperaturaMaxima, Ativa)
VALUES (count+1, descricao, investigador, current_timestamp() , nratos, limitesRatos,  segSemMovi, tempIdeal, variacaoMax, 0);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Criar_Utilizador` (IN `Nome` VARCHAR(100), IN `Telefone` VARCHAR(12), IN `TipoUtilizador` VARCHAR(3), IN `Email` VARCHAR(100))   BEGIN

INSERT INTO utilizador (NomeUtilizador, TelefoneUtilizador, TipoUtilizador, EmailUtilizador, Ativo,NúmeroExperiências)
VALUES (Nome,Telefone,TipoUtilizador,Email,true,0);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Cria_Movimentacao` (IN `SalaEntrada` INT, IN `SalaSaida` INT, IN `IDExperiencia` INT)   BEGIN

DECLARE count INT;
SELECT COUNT(*) INTO count FROM experiencia;


INSERT INTO medicoespassagens (IdMedicao, Hora, SalaEntrada, SalaSaida, IDExperiência
)
    VALUES (count +1,current_timestamp(), SalaEntrada,SalaSaida,IDExperiencia); 

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Cria_Odor` (IN `sala` INT, IN `idexperiencia` INT, IN `codigoOdor` VARCHAR(10))   BEGIN

DECLARE number INT;
DECLARE salas INT;

SELECT COUNT(*) INTO salas
FROM odoresexperiencia
WHERE odoresexperiencia.IdExperiencia = IDExperiencia;

SELECT parâmetrosadicionais.NúmeroSalas INTO number
FROM parâmetrosadicionais
WHERE parâmetrosadicionais.IDExperiência = IDExperiencia;



IF(salas < number) THEN
INSERT INTO odoresexperiencia ( Sala, IdExperiencia, CodigoOdor)
VALUES ( sala, idexperiencia, codigoOdor);

ELSEIF( sala > number) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sala inválida! Tente novamente';
ELSE
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nenhuma sala livre para receber odor! Por favor clique em Concluído';

END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Cria_Subs` (IN `nRatos` INT, IN `codigoSubs` VARCHAR(5), IN `idExperiencia` INT)   BEGIN

INSERT INTO substanciaexperiencia ( NumeroRatos, CodigoSubstancia, IDexperiencia)
VALUES (nRatos, codigoSubs, idExperiencia);



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `EditarDescricaoExperiencia` (IN `IDExperiencia` INT, IN `Descricao` TEXT)   BEGIN

		UPDATE experiencia SET Descricao = Descricao WHERE experiencia.IDexperiência = IDExperiencia;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostrar_Outros_Users` (IN `user` VARCHAR(100))   BEGIN

SELECT utilizador.NomeUtilizador, utilizador.TelefoneUtilizador, utilizador.TipoUtilizador, utilizador.EmailUtilizador,utilizador.Ativo 
FROM utilizador 
Where utilizador.EmailUtilizador <> user;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostrar_User` (IN `userID` VARCHAR(50))   BEGIN

	SELECT utilizador.NomeUtilizador, utilizador.TelefoneUtilizador, utilizador.TipoUtilizador,
    utilizador.EmailUtilizador
	FROM utilizador
	WHERE utilizador.NomeUtilizador = userID or utilizador.TelefoneUtilizador = userID
	or utilizador.TipoUtilizador = userID or utilizador.EmailUtilizador = userID 
    and utilizador.Ativo = true;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostra_Alertas` (IN `IDExperiencia` INT)   BEGIN

SELECT *,alerta.IDAlerta,alerta.IDExperiência
FROM alerta
WHERE alerta.IDExperiência = IDExperiencia;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostra_Experiencia` (IN `userMail` VARCHAR(50))   BEGIN
SELECT *, -Investigador
FROM experiencia
WHERE experiencia.Investigador = userMail;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostra_Investigadores` (IN `aux` VARCHAR(3))   BEGIN

SELECT NomeUtilizador, TelefoneUtilizador, EmailUtilizador
FROM utilizador
WHERE TipoUtilizador = aux;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostra_Medicoes_Temperatura` (IN `IDExperiencia` INT)   BEGIN

SELECT medicoestemperatura.IDMedicao,medicoestemperatura.Hora,
medicoestemperatura.Leitura, medicoestemperatura.Sensor
FROM medicoestemperatura
WHERE medicoestemperatura.IDExperiência = IDExperiencia;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostra_Odores` (IN `experienciaID` INT)   BEGIN
SELECT odoresexperiencia.Sala, odoresexperiencia.CodigoOdor
FROM odoresexperiencia
WHERE odoresexperiencia.IdExperiencia = experienciaID;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostra_Passagem` (IN `IDExperiencia` INT)   BEGIN

SELECT medicoespassagens.IdMedicao,medicoespassagens.Hora,
medicoespassagens.SalaEntrada,medicoespassagens.SalaSaida
FROM medicoespassagens
WHERE medicoespassagens.IDExperiência = IDExperiencia;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostra_Substancias` (IN `experienciaID` INT)   BEGIN
SELECT substanciaexperiencia.CodigoSubstancia, substanciaexperiencia.NumeroRatos
FROM substanciaexperiencia
WHERE substanciaexperiencia.IDexperiencia = experienciaID;



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Obter_Ultima_Medicao_Movimento` (IN `IDExperiencia` INT)   BEGIN

select *
from medicoespassagens
Where medicoespassagens.IDExperiência = IDExperiencia
ORDER BY id DESC LIMIT 1;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Obter_Ultima_Medicao_Temperatura` (IN `IDExperiencia` INT)   select *
from medicoestemperatura 
WHERE medicoestemperatura.IDExperiência = IDExperiencia
ORDER BY medicoestemperatura.IDMedicao 
DESC LIMIT 1$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Suspend_User` (IN `userMail` VARCHAR(50))   BEGIN
IF EXISTS (SELECT EmailUtilizador FROM utilizador WHERE Emailutilizador = userMail) THEN
UPDATE utilizador SET Ativo = CASE WHEN Ativo = False THEN True ELSE False END WHERE Emailutilizador = userMail;
END IF;
END$$

--
-- Funções
--
CREATE DEFINER=`root`@`localhost` FUNCTION `getLastExperiencia` (`user` VARCHAR(100)) RETURNS INT(11)  BEGIN

DECLARE id INT;

SELECT experiencia.IDexperiência INTO id
FROM experiencia
WHERE experiencia.Investigador = user 
ORDER BY experiencia.IDexperiência DESC 
LIMIT 1;


RETURN id;


END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getNumSalas` (`IDExperiencia` INT) RETURNS INT(11)  BEGIN

DECLARE number INT;
DECLARE salas INT;

SELECT COUNT(*) INTO salas
FROM odoresexperiencia
WHERE odoresexperiencia.IdExperiencia = IDExperiencia;

SELECT parâmetrosadicionais.NúmeroSalas INTO number
FROM parâmetrosadicionais
WHERE parâmetrosadicionais.IDExperiência = IDExperiencia;

RETURN number - salas;




END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getSalas` (`IDExperiencia` INT) RETURNS INT(11)  BEGIN

DECLARE number INT;

SELECT parâmetrosadicionais.NúmeroSalas INTO  number
From parâmetrosadicionais
WHERE parâmetrosadicionais.IDExperiência = IDExperiencia;


RETURN number;



END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getSumRats` (`IDExperiencia` INT) RETURNS INT(11)  BEGIN
    DECLARE total_ratos INT;
    SELECT SUM(NumeroRatos) INTO total_ratos
    FROM substanciaexperiencia
    WHERE substanciaexperiencia.IDexperiencia = IDExperiencia;
    IF (total_ratos IS NULL) THEN
        RETURN 0;
    ELSE
        RETURN total_ratos;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `Mostra_Tipo_User` (`userID` VARCHAR(100)) RETURNS VARCHAR(3) CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN

DECLARE user_type VARCHAR(3);

SELECT TipoUtilizador into user_type
FROM utilizador
WHERE utilizador.NomeUtilizador = userID 
OR utilizador.EmailUtilizador = userID;

RETURN user_type;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `UserName` (`userid` VARCHAR(100)) RETURNS VARCHAR(100) CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN

DECLARE nome VARCHAR(100);

SELECT NomeUtilizador into nome
FROM utilizador
WHERE utilizador.NomeUtilizador = userID 
OR utilizador.EmailUtilizador = userID;

RETURN nome;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `verifyExperiencia` (`IDExperiencia` INT) RETURNS INT(11)  BEGIN

DECLARE counter INT;
DECLARE count INT;
DECLARE counte INT;

	SELECT COUNT(*) INTO counter FROM medicoespassagens WHERE medicoespassagens.IDExperiência = IDExperiencia;

	SELECT COUNT(*) INTO counte FROM medicoestemperatura WHERE medicoestemperatura.IDExperiência = IDExperiencia;


	SELECT experiencia.Ativa INTO count FROM experiencia
    WHERE experiencia.IDexperiência =IDExperiencia;



RETURN counter + count + counte ;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `alerta`
--

CREATE TABLE `alerta` (
  `IDAlerta` int(11) NOT NULL,
  `Hora` timestamp NOT NULL DEFAULT current_timestamp(),
  `Sala` int(11) NOT NULL,
  `Sensor` int(11) NOT NULL,
  `Leitura` decimal(4,2) NOT NULL,
  `TipoAlerta` varchar(20) NOT NULL,
  `Mensagem` varchar(100) NOT NULL,
  `horaescrita` timestamp NOT NULL DEFAULT current_timestamp(),
  `IDExperiência` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `alerta`
--

INSERT INTO `alerta` (`IDAlerta`, `Hora`, `Sala`, `Sensor`, `Leitura`, `TipoAlerta`, `Mensagem`, `horaescrita`, `IDExperiência`) VALUES
(1, '2023-03-17 11:50:56', 3, 23, 9.00, 'temp alta', 'tas lixado', '2023-03-17 11:50:56', 6);

-- --------------------------------------------------------

--
-- Estrutura da tabela `experiencia`
--

CREATE TABLE `experiencia` (
  `IDexperiência` int(11) NOT NULL,
  `Descricao` text DEFAULT NULL,
  `Investigador` varchar(50) NOT NULL,
  `DataHora` timestamp NOT NULL DEFAULT current_timestamp(),
  `NumeroRatos` int(11) NOT NULL,
  `LimiteRatosSala` int(11) NOT NULL,
  `SegundosSemMovimento` int(11) NOT NULL,
  `TemperaturaIdeal` decimal(4,2) NOT NULL,
  `VariacaoTemperaturaMaxima` decimal(4,2) NOT NULL,
  `Ativa` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `experiencia`
--

INSERT INTO `experiencia` (`IDexperiência`, `Descricao`, `Investigador`, `DataHora`, `NumeroRatos`, `LimiteRatosSala`, `SegundosSemMovimento`, `TemperaturaIdeal`, `VariacaoTemperaturaMaxima`, `Ativa`) VALUES
(1, 'gg', 'mmonteiro036@gmail.com', '2023-03-15 14:11:36', 34, 4, 5, 4.00, 4.00, 1),
(2, 'rr', 'mmm@gmail.com', '2023-03-15 18:46:37', 89, 67, 3, 99.00, 2.00, 0),
(3, 'Experiencia teste', 'mmm@gmail.com', '2023-03-17 11:59:28', 34, 0, 67, 23.00, 30.00, 0),
(4, 'Experiencia teste', 'mmm@gmail.com', '2023-03-17 12:07:22', 34, 3, 67, 23.00, 30.00, 0),
(5, 'Experiencia CDSI3.0', 'mmm@gmail.com', '2023-03-17 19:06:53', 78, 8, 45, 89.00, 12.00, 0),
(6, 'gggg', 'alice@gmail.com', '2023-04-28 16:42:23', 89, 4, 5, 4.00, 0.00, 0),
(7, 'Nova experiência teste', 'rodrigo@gmail.com', '2023-04-30 11:48:03', 22, 2, 2, 2.00, 2.00, 0),
(8, 'Nova experiência teste', 'rodrigo@gmail.com', '2023-04-30 14:10:13', 33, 4, 6, 6.00, 6.00, 0),
(9, 'Nova experiência teste', 'rodrigo@gmail.com', '2023-04-30 14:13:58', 10, 2, 2, 2.00, 2.00, 0),
(10, 'Nova experiência teste', 'rodrigo@gmail.com', '2023-04-30 15:39:48', 6, 3, 3, 3.00, 3.00, 0),
(11, 'Todos os ratos com substâncias', 'rodrigo@gmail.com', '2023-04-30 15:43:24', 6, 2, 5, 10.00, 1.00, 0),
(12, 'Editar Descrição', 'rodrigo@gmail.com', '2023-04-30 16:28:29', 10, 2, 2, 2.00, 2.00, 0),
(13, 'Todos os ratos com substâncias', 'rodrigo@gmail.com', '2023-04-30 16:44:32', 10, 3, 3, 3.00, 3.00, 0),
(14, 'Todos os ratos com substâncias', 'rodrigo@gmail.com', '2023-04-30 17:04:29', 20, 56, 565, 65.00, 56.00, 0);

--
-- Acionadores `experiencia`
--
DELIMITER $$
CREATE TRIGGER `contaExperiencia` AFTER INSERT ON `experiencia` FOR EACH ROW BEGIN
  DECLARE experiencias INT;

  SELECT NúmeroExperiências INTO experiencias 
  FROM utilizador
  WHERE EmailUtilizador = NEW.Investigador;

  UPDATE utilizador
  SET NúmeroExperiências = experiencias + 1
  WHERE EmailUtilizador = NEW.Investigador;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `elimina_IDexperiencia` BEFORE DELETE ON `experiencia` FOR EACH ROW BEGIN
  DELETE FROM odoresexperiencia
  WHERE IdExperiencia = OLD.IDexperiência; 
  DELETE FROM substanciaexperiencia
  WHERE IDexperiencia = OLD.IDexperiência;
  DELETE FROM medicoessalas
  WHERE IDExperiencia = OLD.IDExperiência;
  DELETE FROM medicoessalas
  WHERE IDExperiência = Old.IDExperiência;
  DELETE FROM medicoestemperatura
  WHERE IDExperiência = OLD.IDExperiência;
   DELETE FROM alerta
  WHERE IDExperiência = OLD.IDExperiência;
  
  
 
  
  
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `verificaUser` BEFORE INSERT ON `experiencia` FOR EACH ROW BEGIN
  DECLARE count INT;
  
  IF NOT EXISTS(SELECT 1 FROM utilizador WHERE utilizador.EmailUtilizador = NEW.Investigador AND utilizador.TipoUtilizador = 'INV' AND utilizador.Ativo = 1 ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O User não pode criar experiências';
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `medicoespassagens`
--

CREATE TABLE `medicoespassagens` (
  `IdMedicao` int(11) NOT NULL,
  `Hora` timestamp NOT NULL DEFAULT current_timestamp(),
  `SalaEntrada` int(11) NOT NULL,
  `SalaSaida` int(11) NOT NULL,
  `IDExperiência` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `medicoespassagens`
--

INSERT INTO `medicoespassagens` (`IdMedicao`, `Hora`, `SalaEntrada`, `SalaSaida`, `IDExperiência`) VALUES
(1, '2023-03-17 20:12:00', 3, 4, 5),
(6, '2023-04-28 15:44:51', 1, 2, 2),
(8, '2023-04-28 21:41:30', 1, 2, 6);

--
-- Acionadores `medicoespassagens`
--
DELIMITER $$
CREATE TRIGGER `passagemRatos` AFTER INSERT ON `medicoespassagens` FOR EACH ROW BEGIN
DECLARE count INT;
DECLARE counter INT;

SET count = (SELECT NumeroRatosFinal FROM medicoessalas WHERE Sala = new.SalaEntrada);
SET counter = (SELECT NumeroRatosFinal FROM medicoessalas WHERE Sala = new.SalaSaida);

UPDATE medicoessalas SET NumeroRatosFinal = count + 1 WHERE Sala = new.SalaEntrada AND medicoessalas.IDExperiencia = new.IDExperiência;
UPDATE medicoessalas SET NumeroRatosFinal = counter - 1 WHERE Sala = new.SalaSaida AND medicoessalas.IDExperiencia
 = new.IDExperiência;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `medicoessalas`
--

CREATE TABLE `medicoessalas` (
  `IDExperiencia` int(11) NOT NULL,
  `NumeroRatosFinal` int(11) NOT NULL,
  `Sala` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `medicoessalas`
--

INSERT INTO `medicoessalas` (`IDExperiencia`, `NumeroRatosFinal`, `Sala`) VALUES
(3, 33, 1),
(3, 2, 2),
(3, 34, 9),
(5, 1, 3),
(5, 1, 4),
(6, 2, 4);

--
-- Acionadores `medicoessalas`
--
DELIMITER $$
CREATE TRIGGER `verificaUpdateRatos` BEFORE UPDATE ON `medicoessalas` FOR EACH ROW BEGIN

DECLARE count INT;
DECLARE id INT;
DECLARE sala int;

SELECT COUNT(*) INTO count FROM alerta;

SET id = new.IDExperiencia;

SET sala = new.Sala;


INSERT INTO alerta (IDAlerta, Hora, Sala, IDExperiência)
VALUES (count +1, current_timestamp(),  sala  ,   id  );  


END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `medicoestemperatura`
--

CREATE TABLE `medicoestemperatura` (
  `IDMedicao` int(11) NOT NULL,
  `Hora` timestamp NULL DEFAULT current_timestamp(),
  `Leitura` decimal(4,2) NOT NULL,
  `Sensor` int(11) NOT NULL,
  `IDExperiência` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `medicoestemperatura`
--

INSERT INTO `medicoestemperatura` (`IDMedicao`, `Hora`, `Leitura`, `Sensor`, `IDExperiência`) VALUES
(1, '2023-04-19 14:48:08', 9.00, 23, 1),
(2, '2023-04-19 14:48:41', 9.00, 24, 2),
(3, '2023-04-30 18:17:05', 9.00, 23, 12);

-- --------------------------------------------------------

--
-- Estrutura da tabela `odoresexperiencia`
--

CREATE TABLE `odoresexperiencia` (
  `Sala` int(11) NOT NULL,
  `IdExperiencia` int(11) NOT NULL,
  `CodigoOdor` varchar(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `odoresexperiencia`
--

INSERT INTO `odoresexperiencia` (`Sala`, `IdExperiencia`, `CodigoOdor`) VALUES
(1, 12, 'err'),
(1, 13, 'mmm'),
(2, 12, 'ert'),
(2, 13, 'rft'),
(3, 1, '67ff'),
(3, 6, '67ff'),
(3, 11, '67ff'),
(3, 12, 'tyu'),
(4, 1, '67ff'),
(6, 11, 'tyh'),
(7, 1, 'rte'),
(9, 1, 'ght');

--
-- Acionadores `odoresexperiencia`
--
DELIMITER $$
CREATE TRIGGER `verificaSalaExperiencia` BEFORE INSERT ON `odoresexperiencia` FOR EACH ROW BEGIN
  IF EXISTS(SELECT 1 FROM odoresexperiencia WHERE odoresexperiencia.Sala = NEW.Sala AND odoresexperiencia.IdExperiencia = NEW.IDExperiencia) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Os valores já existem na tabela';
  END IF;
  IF EXISTS (SELECT 1
      FROM parâmetrosadicionais
      WHERE parâmetrosadicionais.IDExperiência = NEW.IDExperiencia AND parâmetrosadicionais.NúmeroSalas < NEW.Sala) THEN 
          SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Essa sala não existe';
  
  
  END IF;
  
  
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `parâmetrosadicionais`
--

CREATE TABLE `parâmetrosadicionais` (
  `IDExperiência` int(11) NOT NULL,
  `NúmeroSalas` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `parâmetrosadicionais`
--

INSERT INTO `parâmetrosadicionais` (`IDExperiência`, `NúmeroSalas`) VALUES
(6, 22),
(11, 20),
(12, 3),
(13, 3);

-- --------------------------------------------------------

--
-- Estrutura da tabela `substanciaexperiencia`
--

CREATE TABLE `substanciaexperiencia` (
  `NumeroRatos` int(11) NOT NULL,
  `CodigoSubstancia` varchar(5) NOT NULL,
  `IDexperiencia` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `substanciaexperiencia`
--

INSERT INTO `substanciaexperiencia` (`NumeroRatos`, `CodigoSubstancia`, `IDexperiencia`) VALUES
(10, 'edf', 13),
(10, 'frt', 12),
(4, 'gbn', 11),
(1, 'hgd', 11),
(5, 'mmm', 14),
(1, 'mni', 11),
(10, 'rrr', 14);

-- --------------------------------------------------------

--
-- Estrutura da tabela `utilizador`
--

CREATE TABLE `utilizador` (
  `NomeUtilizador` varchar(100) NOT NULL,
  `TelefoneUtilizador` varchar(12) NOT NULL,
  `TipoUtilizador` varchar(3) NOT NULL,
  `EmailUtilizador` varchar(50) NOT NULL,
  `Ativo` tinyint(1) NOT NULL,
  `NúmeroExperiências` int(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `utilizador`
--

INSERT INTO `utilizador` (`NomeUtilizador`, `TelefoneUtilizador`, `TipoUtilizador`, `EmailUtilizador`, `Ativo`, `NúmeroExperiências`) VALUES
('Alice', '934265876', 'INV', 'alice@gmail.com', 1, 1),
('Bruno', '666999111', 'ADM', 'bruno@gmail.com', 1, 0),
('Carapinhzzz', '918911676', 'TEC', 'carapinhzzz@gmail.com', 1, 0),
('Malaquias Lobo', '678342109', 'TEC', 'malaquias@outlook.com', 1, 0),
('Miguelito', '567432111', 'INV', 'mmm@gmail.com', 1, 2),
('MIGUEL', '910349080', 'INV', 'mmonteiro036@gmail.com', 1, 0),
('Paulo', '548999999', 'INV', 'pedroloule@hotmail.com', 1, 0),
('Pedro', '567346111', 'ADM', 'pedrolouro@hotmail.com', 1, 0),
('Rodrigo', '918934967', 'INV', 'rodrigo@gmail.com', 1, 8),
('Vasco', '910349086', 'ADM', 'vasquinho@iscte-iu.pt', 1, 0);

--
-- Índices para tabelas despejadas
--

--
-- Índices para tabela `alerta`
--
ALTER TABLE `alerta`
  ADD PRIMARY KEY (`IDAlerta`),
  ADD KEY `IDExperiência` (`IDExperiência`);

--
-- Índices para tabela `experiencia`
--
ALTER TABLE `experiencia`
  ADD PRIMARY KEY (`IDexperiência`),
  ADD KEY `Investigador` (`Investigador`);

--
-- Índices para tabela `medicoespassagens`
--
ALTER TABLE `medicoespassagens`
  ADD PRIMARY KEY (`IdMedicao`),
  ADD KEY `IDExperiência` (`IDExperiência`);

--
-- Índices para tabela `medicoessalas`
--
ALTER TABLE `medicoessalas`
  ADD PRIMARY KEY (`IDExperiencia`,`Sala`),
  ADD KEY `Sala` (`Sala`);

--
-- Índices para tabela `medicoestemperatura`
--
ALTER TABLE `medicoestemperatura`
  ADD PRIMARY KEY (`IDMedicao`),
  ADD KEY `IDExperiência` (`IDExperiência`);

--
-- Índices para tabela `odoresexperiencia`
--
ALTER TABLE `odoresexperiencia`
  ADD PRIMARY KEY (`Sala`,`IdExperiencia`),
  ADD KEY `IdExperiencia` (`IdExperiencia`);

--
-- Índices para tabela `parâmetrosadicionais`
--
ALTER TABLE `parâmetrosadicionais`
  ADD PRIMARY KEY (`IDExperiência`);

--
-- Índices para tabela `substanciaexperiencia`
--
ALTER TABLE `substanciaexperiencia`
  ADD PRIMARY KEY (`CodigoSubstancia`,`IDexperiencia`),
  ADD KEY `IDexperiencia` (`IDexperiencia`);

--
-- Índices para tabela `utilizador`
--
ALTER TABLE `utilizador`
  ADD PRIMARY KEY (`EmailUtilizador`),
  ADD UNIQUE KEY `TelefoneUtilizador` (`TelefoneUtilizador`);

--
-- AUTO_INCREMENT de tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `alerta`
--
ALTER TABLE `alerta`
  MODIFY `IDAlerta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de tabela `experiencia`
--
ALTER TABLE `experiencia`
  MODIFY `IDexperiência` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de tabela `medicoespassagens`
--
ALTER TABLE `medicoespassagens`
  MODIFY `IdMedicao` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de tabela `medicoestemperatura`
--
ALTER TABLE `medicoestemperatura`
  MODIFY `IDMedicao` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Restrições para despejos de tabelas
--

--
-- Limitadores para a tabela `alerta`
--
ALTER TABLE `alerta`
  ADD CONSTRAINT `alerta_ibfk_1` FOREIGN KEY (`IDExperiência`) REFERENCES `experiencia` (`IDexperiência`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `experiencia`
--
ALTER TABLE `experiencia`
  ADD CONSTRAINT `experiencia_ibfk_1` FOREIGN KEY (`Investigador`) REFERENCES `utilizador` (`EmailUtilizador`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `medicoespassagens`
--
ALTER TABLE `medicoespassagens`
  ADD CONSTRAINT `medicoespassagens_ibfk_1` FOREIGN KEY (`IDExperiência`) REFERENCES `experiencia` (`IDexperiência`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `medicoessalas`
--
ALTER TABLE `medicoessalas`
  ADD CONSTRAINT `medicoessalas_ibfk_1` FOREIGN KEY (`IDExperiencia`) REFERENCES `experiencia` (`IDexperiência`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `medicoestemperatura`
--
ALTER TABLE `medicoestemperatura`
  ADD CONSTRAINT `medicoestemperatura_ibfk_1` FOREIGN KEY (`IDExperiência`) REFERENCES `experiencia` (`IDexperiência`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `odoresexperiencia`
--
ALTER TABLE `odoresexperiencia`
  ADD CONSTRAINT `odoresexperiencia_ibfk_1` FOREIGN KEY (`IdExperiencia`) REFERENCES `experiencia` (`IDexperiência`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `parâmetrosadicionais`
--
ALTER TABLE `parâmetrosadicionais`
  ADD CONSTRAINT `IDExperiência` FOREIGN KEY (`IDExperiência`) REFERENCES `experiencia` (`IDexperiência`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `substanciaexperiencia`
--
ALTER TABLE `substanciaexperiencia`
  ADD CONSTRAINT `substanciaexperiencia_ibfk_1` FOREIGN KEY (`IDexperiencia`) REFERENCES `experiencia` (`IDexperiência`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
