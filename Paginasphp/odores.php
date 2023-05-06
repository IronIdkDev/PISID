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
        if(empty($username) || empty($password)){
            header("Location: erro.php");
        }
        $conn = new mysqli($servername, $username, $password, $dbname);
        // Verifica a conexão
        if ($conn->connect_error) {
            die("Conexão falhou: " . $conn->connect_error);
        }

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




// Nome da function que será usada
$functionName = "getLastExperiencia";

// Prepara a function para ser chamada
$stmt = $conn->prepare("SELECT $functionName(?) AS resultado");

// Define o valor do parâmetro da função
$stmt->bind_param('s', $username);

// Executa a function
$stmt->execute();

// Guarda o valor retornado pela function
$result = $stmt->get_result();

// Guarda numa variável o valor da function
$id = $result->fetch_assoc()['resultado'];

//Mesma coisa que acima mas agora com o número das salas. É basicamente igual ao que é usado na página ratos.php

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

//Se o valor inserido no formulário for superior ao número de salas então devolve um erro pop-up
if($sala < $num){

    $conn->query($sql);
    echo"<h4>Dados inseridos com sucesso</h4>";
    header("refresh: 0.1");
}else if($sala == $num ){
    $conn->query($sql);
    echo"<h4>Dados inseridos com sucesso</h4>";
    header("Location: homeINV.php");

}else{
    echo"<script>alert(\"ERRO! O número inserido é superior ao permitido! Preencha novamente ou clique em Concluído\");
</script>";
}


}else if(isset($_POST['Concluído'])) {
    header("Location: homeINV.php");
}

?>




</html>