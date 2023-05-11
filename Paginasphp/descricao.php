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
        $id = $_SESSION['id'];

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


	?>

	<title>Página de Investigador</title>
    	<link rel="stylesheet" type="text/css" href="ratos.css">
    </head>

    <body>
<h1>Editar Descrição da experiência <?php echo $id ?> </h1>
<form method="post">
				<label for="editar">Descrição:</label>
                <input type="text" name="editar" id="editar" maxlength="100" required>
                <input type="submit" name= "editarDescricao" value="Editar Descrição">
</form>
    </body>
<?php

if(isset($_POST['editar'])) {
$editar = $_POST['editar'];

$sql = "CALL EditarDescricaoExperiencia('$id','$editar');";
$result = $conn->query($sql);

header("Location: homeINV.php");

}

?>
</html>