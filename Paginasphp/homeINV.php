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
	?>

	<title>Página de TEC</title>

	<!-- Inclui o ficheiro CSS para o tema de Ratos -->
	<link rel="stylesheet" type="text/css" href="ratos.css">
</head>

<body>
	<h1 class="titulo-principal">Bem-vindo <?php echo $name; ?></h1>
    </body>
</html>