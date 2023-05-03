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
<input type="submit" name="avancar" value="Avançar">
</form>

</body>

<?php

if(isset($_POST['adicionar'])) {


    $ratosAux = $_POST['numeroRatos'];
    $codigoSub = $_POST['codigoSub'];


// Representa o nome da function que será chamada
$functionName = "getLastExperiencia";
//Prepara a function para ser chamada
$stmt = $conn->prepare("SELECT $functionName(?) AS resultado");
// Define o valor do parâmetro da função
$stmt->bind_param('s', $username);
// Executa a function
$stmt->execute();
// Recebe o resultado retornado pela function
$result = $stmt->get_result();
// Guarda o resultado retornado pela function
$id = $result->fetch_assoc()['resultado'];

$sql = "CALL Cria_Subs('$ratosAux','$codigoSub','$id');";

//Verifica se o valor inserido no formulário é superior ao valor de ratos que faltam admistrar substâncias
if($ratosAux > $ratos){

echo"<script>alert(\"ERRO! O número inserido é superior ao permitido! Preencha novamente ou clique em Avançar\");
</script>";

}else if ($ratosAux == $ratos){
    $conn->query($sql);
    header("Location: odores.php");

}else{

$conn->query($sql);

$_SESSION['numeroRatos'] = $ratos - $ratosAux;
//Faz um refresh à página para mostrar o valor de $ratos estar atualizado
header("refresh:0.1");

}

}else if(isset($_POST['avancar'])) {
    header("Location: odores.php");
}
?>

</html>