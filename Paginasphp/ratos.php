<!DOCTYPE html>
<html>
<head>
	<?php
		//Passa os dados da conexão da página anterior
		session_start();
		$servername = $_SESSION['servername'];
		$username = $_SESSION['username'];
		$password = $_SESSION['password'];
		$dbname = $_SESSION['dbname'];
		$name = $_SESSION['nome'];
        $ratos = $_SESSION['numeroRatos'];

        $conn = new mysqli($servername, $username, $password, $dbname);

        // Verifica a conexão
        if ($conn->connect_error) {
            die("Conexão falhou: " . $conn->connect_error);
        }


	?>

<title>Página de Investigador</title>
    	<!-- Inclui o ficheiro CSS para o tema de Ratos -->
    	<link rel="stylesheet" type="text/css" href="ratos.css">

</head>


<body>

<h1>Formulário de Substância</h1>
<h3>Número de ratos: <?php echo $ratos ?></h3>  

<form method = "post">
<label for="numeroRatos">Número de ratos:</label>
<input type="number" name="numeroRatos" required>

<label for="codigoSub">Código da Substância:</label>
<input type="text" name="codigoSub" required>

<input type="submit" name="adicionar" value="adicionar">

</form>

<form method = "post">
<input type="submit" name="avancar" value="avancar">
</form>

</body>

<?php

if(isset($_POST['adicionar'])) {


    $ratosAux = $_POST['numeroRatos'];
    $codigoSub = $_POST['codigoSub'];


// Define o nome da função que você quer chamar
$functionName = "getLastExperiencia";

// Prepara a chamada da função
$stmt = $conn->prepare("SELECT $functionName(?) AS resultado");

// Define o valor do parâmetro da função
$stmt->bind_param('s', $username);

// Executa a consulta
$stmt->execute();

// Obtém o resultado da consulta
$result = $stmt->get_result();

// Obtém o valor retornado pela função
$id = $result->fetch_assoc()['resultado'];



// Define o nome da função que você quer chamar
$functionName1 = "getSumRats";

// Prepara a chamada da função
$stmt1 = $conn->prepare("SELECT $functionName1(?) AS soma");

// Define o valor do parâmetro da função
$stmt1->bind_param('s', $id);

// Executa a consulta
$stmt1->execute();

// Obtém o resultado da consulta
$result1 = $stmt1->get_result();

// Obtém o valor retornado pela função
$nRatos = $result1->fetch_assoc()['soma'];

if(($nRatos + $ratosAux) >= $ratos){
    $ratosAux = $ratos-$nRatos;
    $sql = "CALL Cria_Subs('$ratosAux','$codigoSub','$id');";
    $conn->query($sql);
    header("Location: odores.php");	
}else {

    $nRatos += $ratosAux;
$sql = "CALL Cria_Subs('$ratosAux','$codigoSub','$id');";
$conn->query($sql);

$_SESSION['numeroRatos'] = $ratos - $ratosAux;
header("refresh:0.1");

}

}else if(isset($_POST['avancar'])) {
    header("Location: odores.php");
}
?>

</html>