<!DOCTYPE html>
<html>

<?php
//Passa os dados da conexão da página anterior
session_start();
$servername = $_SESSION['servername'];
$username = $_SESSION['username'];
$password = $_SESSION['password'];
$dbname = $_SESSION['dbname'];
$name = $_SESSION['nome'];
$id = $_SESSION['id'];
$idmedicao = $_SESSION['idmedicao'];

if(empty($username) || empty($password)){
    header("Location: erro.php");
}
$conn = new mysqli($servername, $username, $password, $dbname);

// Verifica a conexão
if ($conn->connect_error) {
	die("Conexão falhou: " . $conn->connect_error);
}else{

// Nome da funntion
$functionTipo = "Mostra_Tipo_User";
// Prepara a function
$stmtTipo = $conn->prepare("SELECT $functionTipo(?) AS resultado");
// Define o valor do parâmetro da function
$stmtTipo->bind_param('s', $username);
// Faz a consulta
$stmtTipo->execute();
// Obtém o resultado da consulta
$resultTipo = $stmtTipo->get_result();
// Guarda o valor retornado pela function
$resultadoTipo = $resultTipo->fetch_assoc()['resultado'];
if($resultadoTipo == "ADM" ||$resultadoTipo == "TEC"){
    header("Location: erro.php");
}



// Nome da funntion
$function = "getSumRats";
// Prepara a function
$stmt = $conn->prepare("SELECT $function(?, ?) AS resultado");
// Define o valor do parâmetro da function
$stmt->bind_param('ss',$id ,$idmedicao);
// Faz a consulta
$stmt->execute();
// Obtém o resultado da consulta
$result = $stmt->get_result();
// Guarda o valor retornado pela function
$resultado = $result->fetch_assoc()['resultado'];	
$resultadoInt = intval($resultado);

// Nome da funntion
$function = "getNumRatos";
// Prepara a function
$stmt = $conn->prepare("SELECT $function(?) AS resultado");
// Define o valor do parâmetro da function
$stmt->bind_param('s',$id);
// Faz a consulta
$stmt->execute();
// Obtém o resultado da consulta
$result = $stmt->get_result();
// Guarda o valor retornado pela function
$resultado = $result->fetch_assoc()['resultado'];	
$resultadoRatos = intval($resultado);


}


?>

<title>Editar Substância-> Número de ratos disponível</title>
	<link rel="stylesheet" type="text/css" href="ratos.css">
</head>

<body>


<h1>Editar Substância-> Número de ratos disponível <?php echo $resultadoRatos - $resultadoInt; ?></h1>
<form method="post">

<label for="numeroRatos">Número de ratos:</label>
                <input type="number" name="numeroRatos" required>
                <label for="codigoSub">Código da Substância:</label>
<input type="text" name="codigoSub" required>

<input type="submit" name="adicionar" value="adicionar">                
</form>
<form method="post">

<input type="submit" name="delete" value="Apagar Substância">
<input type="submit" name="Voltar" value="Voltar">

</form>
</body>

<?php

		// Realizar a consulta
		if(isset($_POST["delete"])) {
            $sql = "CALL Delete_Sub('$idmedicao');";
            $result = $conn->query($sql);
            header("Location: detalhes.php");

        }else if(isset($_POST['adicionar'])) {


            $ratos = $_POST['numeroRatos'];
            $codigoSub = $_POST['codigoSub'];

            if($ratos > $resultadoRatos){
                echo"<script>alert(\"ERRO! O número inserido é superior ao permitido! Preencha novamente ou clique em Avançar\");</script>";

            }else {
             
            try { 
            $sql = "CALL Editar_Sub('$idmedicao','$ratos', '$codigoSub', $id );";
            $result = $conn->query($sql);
                header("Location: detalhes.php");
            } catch (Exception $e) {
                echo $e->getMessage();
            }
            }

        }else if(isset($_POST["Voltar"])) {
            header("Location: detalhes.php");
        }

        ?>

</html>
