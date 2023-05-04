-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 04-Maio-2023 às 15:07
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `Atribui_Odor` (IN `Sala` INT, IN `IDExperiencia` INT, IN `Odor` VARCHAR(5))   BEGIN

INSERT INTO odoresexperiencia ( Sala, IdExperiencia, CodigoOdor)
VALUES (Sala, IDExperiencia, Odor);


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Atribui_Sub` (IN `NumeroRatos` INT, IN `CodigoSubstancia` VARCHAR(5), IN `IDExperiencia` INT)   BEGIN

INSERT INTO substanciaexperiencia ( NumeroRatos, CodigoSubstancia, IDexperiencia)
VALUES (NumeroRatos, CodigoSubstancia, IDExperiencia);

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

CREATE DEFINER=`root`@`localhost` PROCEDURE `Cria_Medicao_Temp` (IN `leitura` DECIMAL, IN `sensor` INT, IN `outlier` TINYINT)   BEGIN 

DECLARE count INT;
DECLARE id INT;
DECLARE counter INT;

SELECT COUNT(*) INTO count FROM medicoestemperatura;

SELECT COUNT(*) INTO counter 
FROM experiencia
WHERE experiencia.Ativa = 1;

IF(counter = 0)THEN
SET id = 0;
ELSE 
SELECT experiencia.IDexperiência INTO id
FROM experiencia
WHERE experiencia.Ativa = 1;
END IF;

INSERT INTO medicoestemperatura (IDMedicao, Hora, Leitura, Sensor, IDExperiência,Outlier)
    VALUES (count +1,current_timestamp(), leitura,sensor,id,outlier); 





END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Cria_Movimentacao` (IN `SalaEntrada` INT, IN `SalaSaida` INT)   BEGIN

DECLARE count INT;
DECLARE id INT;
DECLARE counter INT;
SELECT COUNT(*) INTO count FROM medicoespassagens;

SELECT COUNT(*) INTO counter 
FROM experiencia
WHERE experiencia.Ativa = 1;

IF(counter = 0)THEN
SET id = 0;
ELSE 
SELECT experiencia.IDexperiência INTO id
FROM experiencia
WHERE experiencia.Ativa = 1;

	IF(SalaEntrada = 0 AND SalaSaida = 0)THEN
		UPDATE experiencia SET Ativa = 0 WHERE experiencia.IDexperiência = id;
    END IF;

END IF;

INSERT INTO medicoespassagens (IdMedicao, Hora, SalaEntrada, SalaSaida, IDExperiência)
    VALUES (count +1,current_timestamp(), SalaEntrada,SalaSaida,id); 

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Cria_Odor` (IN `sala` INT, IN `idexperiencia` INT, IN `codigoOdor` VARCHAR(10))   BEGIN
DECLARE counter INT;
SELECT COUNT(*) INTO counter
FROM odoresexperiencia;

INSERT INTO odoresexperiencia (IDMedicao, Sala, IdExperiencia, CodigoOdor)
VALUES ( counter+1, sala, idexperiencia, codigoOdor);



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Cria_Subs` (IN `nRatos` INT, IN `codigoSubs` VARCHAR(5), IN `idExperiencia` INT)   BEGIN

DECLARE counter INT;
SELECT COUNT(*) INTO counter
FROM substanciaexperiencia;

INSERT INTO substanciaexperiencia ( IDMedicao, NumeroRatos, CodigoSubstancia, IDexperiencia)
VALUES (counter+1, nRatos, codigoSubs, idExperiencia);



END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Delete_Odor` (IN `id` INT)   BEGIN

DELETE FROM odoresexperiencia
WHERE odoresexperiencia.IDMedicao = id;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Delete_Sub` (IN `id` INT)   BEGIN

DELETE FROM substanciaexperiencia
WHERE substanciaexperiencia.IDMedicao = id;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `EditarDescricaoExperiencia` (IN `IDExperiencia` INT, IN `Descricao` TEXT)   BEGIN

UPDATE experiencia SET Descricao = Descricao WHERE experiencia.IDexperiência = IDExperiencia;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Editar_Sub` (IN `id` INT, IN `ratos` INT, IN `codigo` VARCHAR(3), IN `idexp` INT)   BEGIN

DECLARE nratos INT;
DECLARE num INT;
DECLARE counter INT;
SELECT getSumRats(idexp, id) INTO nratos;

SELECT experiencia.NumeroRatos INTO num
FROM experiencia
WHERE experiencia.IDexperiência = idexp;

SELECT COUNT(*) INTO counter
FROM substanciaexperiencia
WHERE substanciaexperiencia.IDexperiencia = id 
AND substanciaexperiencia.CodigoSubstancia = codigo;

SELECT nratos, ratos, counter, num;

IF(num >= (nratos + ratos) AND counter = 0)THEN

UPDATE substanciaexperiencia SET substanciaexperiencia.NumeroRatos = ratos
WHERE substanciaexperiencia.IDMedicao = id;
UPDATE substanciaexperiencia SET substanciaexperiencia.CodigoSubstancia = codigo 
WHERE substanciaexperiencia.IDMedicao = id;
ELSE

    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não foi possível editar';

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Edita_Odor` (IN `id` INT, IN `sala` INT, IN `codigo` VARCHAR(3), IN `idexp` INT)   BEGIN

DECLARE counter INT;
DECLARE counter2 INT;

SELECT COUNT(*) INTO counter
FROM odoresexperiencia
WHERE odoresexperiencia.Sala = sala
AND odoresexperiencia.IdExperiencia = idexp
AND odoresexperiencia.CodigoOdor = codigo;

SELECT COUNT(*) INTO counter2
FROM odoresexperiencia
WHERE odoresexperiencia.Sala = sala
AND odoresexperiencia.IdExperiencia = idexp
AND odoresexperiencia.IDMedicao <> id;

IF(counter = 0 AND counter2 = 0) THEN

    UPDATE odoresexperiencia SET Sala = sala
    WHERE odoresexperiencia.IDMedicao = id;

    UPDATE odoresexperiencia SET CodigoOdor = codigo
    WHERE odoresexperiencia.IDMedicao = id;

ELSE 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não foi possível editar';
END IF;

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

IF( IDExperiencia = -1 )THEN
	SELECT medicoestemperatura.IDMedicao,medicoestemperatura.Hora,
	medicoestemperatura.Leitura, medicoestemperatura.Sensor
	FROM medicoestemperatura;
ELSE
	SELECT medicoestemperatura.IDMedicao,medicoestemperatura.Hora,
	medicoestemperatura.Leitura, medicoestemperatura.Sensor
	FROM medicoestemperatura
	WHERE medicoestemperatura.IDExperiência = IDExperiencia;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostra_Odores` (IN `experienciaID` INT)   BEGIN
SELECT odoresexperiencia.IDMedicao ,odoresexperiencia.Sala, odoresexperiencia.CodigoOdor
FROM odoresexperiencia
WHERE odoresexperiencia.IdExperiencia = experienciaID;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostra_Passagem` (IN `IDExperiencia` INT)   BEGIN

IF( IDExperiencia = -1)THEN
SELECT medicoespassagens.IdMedicao,medicoespassagens.Hora,
medicoespassagens.SalaEntrada,medicoespassagens.SalaSaida
FROM medicoespassagens;

ELSE
SELECT medicoespassagens.IdMedicao,medicoespassagens.Hora,
medicoespassagens.SalaEntrada,medicoespassagens.SalaSaida
FROM medicoespassagens
WHERE medicoespassagens.IDExperiência = IDExperiencia;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostra_Salas` (IN `id` INT)   BEGIN

SELECT medicoessalas.NumeroRatosFinal, medicoessalas.Sala
FROM medicoessalas
WHERE medicoessalas.IDExperiencia = id;


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostra_Substancias` (IN `experienciaID` INT)   BEGIN
SELECT substanciaexperiencia.IDMedicao ,substanciaexperiencia.CodigoSubstancia, substanciaexperiencia.NumeroRatos
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `Return_Salas_Utilizadas` (IN `id` INT)   BEGIN

SELECT odoresexperiencia.Sala
FROM odoresexperiencia
WHERE odoresexperiencia.IdExperiencia = id;


END$$

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

CREATE DEFINER=`root`@`localhost` FUNCTION `getLimiteSalas` (`id` INT) RETURNS INT(11)  BEGIN

DECLARE counter INT;

SELECT parâmetrosadicionais.NúmeroSalas INTO counter
FROM parâmetrosadicionais
WHERE parâmetrosadicionais.IDExperiência = id;

RETURN counter;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getNumRatos` (`id` INT) RETURNS INT(11)  BEGIN
DECLARE number INT;

SELECT experiencia.NumeroRatos into number
FROM experiencia
WHERE experiencia.IDexperiência = id;

RETURN number;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getNumSalas` (`id` INT) RETURNS INT(11)  BEGIN

DECLARE counter INT;
DECLARE number INT;

SELECT parâmetrosadicionais.NúmeroSalas INTO counter 
FROM parâmetrosadicionais
WHERE parâmetrosadicionais.IDExperiência = id;

SELECT COUNT(*) INTO number
FROM odoresexperiencia
WHERE odoresexperiencia.IdExperiencia = id;

RETURN counter - number;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getSalas` (`IDExperiencia` INT) RETURNS INT(11)  BEGIN

DECLARE number INT;

SELECT parâmetrosadicionais.NúmeroSalas INTO  number
From parâmetrosadicionais
WHERE parâmetrosadicionais.IDExperiência = IDExperiencia;


RETURN number;



END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getSumRats` (`IDExperiencia` INT, `IDMedicao` INT) RETURNS INT(11)  BEGIN
    DECLARE total_ratos INT;
    DECLARE id INT;
    
    SELECT substanciaexperiencia.NumeroRatos INTO id
    FROM substanciaexperiencia
    WHERE substanciaexperiencia.IDMedicao = IDMedicao;
    
    SELECT SUM(NumeroRatos) INTO total_ratos
    FROM substanciaexperiencia
    WHERE substanciaexperiencia.IDexperiencia = IDExperiencia;
    IF (total_ratos IS NULL) THEN
        RETURN 0;
    ELSE
        RETURN total_ratos - id;
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

CREATE DEFINER=`root`@`localhost` FUNCTION `verifyExperiencia` (`id` INT) RETURNS INT(11)  BEGIN

DECLARE ativo INT;
DECLARE c INT;
DECLARE d INT;

SELECT experiencia.Ativa INTO ativo
FROM experiencia
WHERE experiencia.IDexperiência = id;

SELECT COUNT(*) INTO c 
FROM medicoestemperatura 
WHERE medicoestemperatura.IDExperiência = id;

SELECT COUNT(*) INTO d
FROM medicoespassagens
WHERE medicoespassagens.IDExperiência = id;

RETURN ativo + c+ d;

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
(1, '2023-05-03 11:28:07', 1, 0, 0.00, 'Limite de ratos', 'O limite de ratos de uma sala da experiência foi ultrapassado', '2023-05-03 11:28:07', 2);

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
(0, 'Experiência default. Recebe dados que não pertencem a nenhuma experiência', 'default', '2023-05-02 13:06:04', 0, 0, 0, 0.00, 0.00, 0),
(2, 'Nova experiencia', 'bruno@gmail.com', '2023-05-03 11:10:58', 5, 2, 3, 14.00, 2.00, 0);

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
(1, '2023-05-04 12:58:43', 0, 0, 2);

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
(2, 2, 3);

--
-- Acionadores `medicoessalas`
--
DELIMITER $$
CREATE TRIGGER `verificaUpdateRatos` BEFORE UPDATE ON `medicoessalas` FOR EACH ROW BEGIN

DECLARE count INT;
DECLARE id INT;
DECLARE sala int;
DECLARE ratosSala INT;
DECLARE descricao TEXT;

SET sala = new.Sala;
SET id = new.IDExperiencia;

SELECT experiencia.NumeroRatos INTO ratosSala
FROM experiencia
WHERE experiencia.IDexperiência = id; 


IF(new.NumeroRatosFinal >= ratosSala)THEN
	SELECT COUNT(*) INTO count FROM alerta;
	INSERT INTO alerta (IDAlerta, Hora, Sala, TipoAlerta,Mensagem,horaescrita,IDExperiência)
	VALUES (count +1, current_timestamp(),  sala, 'Limite de ratos','O limite de ratos de uma sala da experiência foi ultrapassado',current_timestamp(), id );  
END IF;

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
  `IDExperiência` int(11) NOT NULL,
  `Outlier` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `medicoestemperatura`
--

INSERT INTO `medicoestemperatura` (`IDMedicao`, `Hora`, `Leitura`, `Sensor`, `IDExperiência`, `Outlier`) VALUES
(1, '2023-05-04 10:45:27', 9.00, 23, 2, 1);

--
-- Acionadores `medicoestemperatura`
--
DELIMITER $$
CREATE TRIGGER `criarAlertaTemp` AFTER INSERT ON `medicoestemperatura` FOR EACH ROW BEGIN

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

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `odoresexperiencia`
--

CREATE TABLE `odoresexperiencia` (
  `Sala` int(11) NOT NULL,
  `IdExperiencia` int(11) NOT NULL,
  `CodigoOdor` varchar(5) NOT NULL,
  `IDMedicao` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `odoresexperiencia`
--

INSERT INTO `odoresexperiencia` (`Sala`, `IdExperiencia`, `CodigoOdor`, `IDMedicao`) VALUES
(2, 2, 'lll', 1),
(1, 2, 'rrr', 2);

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
(2, 3);

--
-- Acionadores `parâmetrosadicionais`
--
DELIMITER $$
CREATE TRIGGER `addSalas` AFTER INSERT ON `parâmetrosadicionais` FOR EACH ROW BEGIN

DECLARE i INT;
DECLARE j INT;

SET j = new.NúmeroSalas;
SET i = 1;

WHILE (i <= j )DO
	INSERT INTO medicoessalas (IDExperiencia, NumeroRatosFinal,Sala) 
    VALUES (new.IDExperiência, 0, i);
    SET i = i + 1;
END WHILE;




END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `substanciaexperiencia`
--

CREATE TABLE `substanciaexperiencia` (
  `NumeroRatos` int(11) NOT NULL,
  `CodigoSubstancia` varchar(5) NOT NULL,
  `IDexperiencia` int(11) NOT NULL,
  `IDMedicao` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Extraindo dados da tabela `substanciaexperiencia`
--

INSERT INTO `substanciaexperiencia` (`NumeroRatos`, `CodigoSubstancia`, `IDexperiencia`, `IDMedicao`) VALUES
(1, 'err', 2, 2);

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
('Alice', '910349808', 'TEC', 'alice@gmail.com', 1, 0),
('Bruno', '999999999', 'INV', 'bruno@gmail.com', 1, 1),
('Default', '000000000', 'INV', 'default', 1, 1),
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
  ADD PRIMARY KEY (`IDMedicao`),
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
  ADD PRIMARY KEY (`IDMedicao`),
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
  MODIFY `IDAlerta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de tabela `experiencia`
--
ALTER TABLE `experiencia`
  MODIFY `IDexperiência` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT de tabela `medicoespassagens`
--
ALTER TABLE `medicoespassagens`
  MODIFY `IdMedicao` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de tabela `medicoestemperatura`
--
ALTER TABLE `medicoestemperatura`
  MODIFY `IDMedicao` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Restrições para despejos de tabelas
--

--
-- Limitadores para a tabela `alerta`
--
ALTER TABLE `alerta`
  ADD CONSTRAINT `alerta_ibfk_1` FOREIGN KEY (`IDExperiência`) REFERENCES `experiencia` (`IDexperiência`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `experiencia`
--
ALTER TABLE `experiencia`
  ADD CONSTRAINT `experiencia_ibfk_1` FOREIGN KEY (`Investigador`) REFERENCES `utilizador` (`EmailUtilizador`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `medicoespassagens`
--
ALTER TABLE `medicoespassagens`
  ADD CONSTRAINT `medicoespassagens_ibfk_1` FOREIGN KEY (`IDExperiência`) REFERENCES `experiencia` (`IDexperiência`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `medicoessalas`
--
ALTER TABLE `medicoessalas`
  ADD CONSTRAINT `medicoessalas_ibfk_1` FOREIGN KEY (`IDExperiencia`) REFERENCES `experiencia` (`IDexperiência`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `medicoestemperatura`
--
ALTER TABLE `medicoestemperatura`
  ADD CONSTRAINT `medicoestemperatura_ibfk_1` FOREIGN KEY (`IDExperiência`) REFERENCES `experiencia` (`IDexperiência`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `odoresexperiencia`
--
ALTER TABLE `odoresexperiencia`
  ADD CONSTRAINT `odoresexperiencia_ibfk_1` FOREIGN KEY (`IdExperiencia`) REFERENCES `experiencia` (`IDexperiência`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `parâmetrosadicionais`
--
ALTER TABLE `parâmetrosadicionais`
  ADD CONSTRAINT `IDExperiência` FOREIGN KEY (`IDExperiência`) REFERENCES `experiencia` (`IDexperiência`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `substanciaexperiencia`
--
ALTER TABLE `substanciaexperiencia`
  ADD CONSTRAINT `substanciaexperiencia_ibfk_1` FOREIGN KEY (`IDexperiencia`) REFERENCES `experiencia` (`IDexperiência`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
