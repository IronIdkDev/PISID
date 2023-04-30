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



$function = "getNumSalas";
$stmt1 = $conn->prepare("SELECT $function(?) AS resultado");
$stmt1->bind_param('s', $id);
$stmt1->execute();
$result1 = $stmt1->get_result();
$num = $result1->fetch_assoc()['resultado'];

	?>

<title>Página de Investigador</title>
    	<!-- Inclui o ficheiro CSS para o tema de Ratos -->
    	<link rel="stylesheet" type="text/css" href="ratos.css">

</head>


<body>
<h1>Formulário de Odores -> Número de salas vagas <?php echo $num ?></h1>
<form method = "post">
<label for="sala">Número da Sala:</label>
<input type="number" name="sala" required>

<label for="odor">Código do Odor:</label>
<input type="text" name="odor" required>

<input type="submit" name="adicionar" value="adicionar">

</form>

<form method = "post">
<input type="submit" name="Concluído" value="Concluído">
</form>

</body>


<?php

if(isset($_POST['adicionar'])) {


$sala = $_POST['sala'];
$odor = $_POST['odor'];



$sql = "CALL Cria_Odor('$sala','$id','$odor' )";

if (mysqli_query($conn, $sql)) {
    echo "Dados inseridos com sucesso.";
    header("refresh:0.1");
} else {
    $erro = mysqli_error($conn);
    $mensagem_erro = substr($erro, 0, strpos($erro, ' in'));

    echo $mensagem_erro; // exibe somente a mensagem de erro desejada
}



}else if(isset($_POST['Concluído'])) {
    header("Location: homeINV.php");
}

?>




</html>