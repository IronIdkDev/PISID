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
<h1>Editar Descrição da experiência <?php echo $id ?> </h1>
<form method="post">
				<label for="editar">Descrição:</label>
                <input type="text" name="editar" id="editar" maxlength="100" required>
                <input type="submit" name= "editar" value="Editar Descrição">
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