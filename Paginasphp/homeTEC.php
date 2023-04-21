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

	<form method="post">
		<label for="idExperiencia">ID de Experiência:</label>
		<input type="number" name="idExperiencia" id="idExperiencia" required>
		<input type="submit" name="submitTemperatura" value="Mostrar medições de temperatura">
		<input type="submit" name="submitMovimento" value="Mostrar medições de movimento">
	</form>
	<form method="post">
    <input type="submit" name="logout" value="Logout">
</form>

	<?php
		// Cria a conexão
		$conn = new mysqli($servername, $username, $password, $dbname);

		// Verifica a conexão
		if ($conn->connect_error) {
		    die("Conexão falhou: " . $conn->connect_error);
		}

		// Realizar a consulta 
		if(isset($_POST["submitTemperatura"])) {

			// Obtém o valor inserido pelo usuário
			$idExperiencia = $_POST["idExperiencia"];

			$inteiro = intval($idExperiencia);

			// Consulta através de sql
			$sql = "CALL Mostra_Medicoes_Temperatura('$inteiro');";
			$result = $conn->query($sql);

			// Se a consulta retornar resultados, mostrar numa tabela
			if ($result->num_rows > 0) {
				echo "<table>";
				echo "<tr><th>IDMedicao</th><th>Hora</th><th>Leitura</th><th>Sensor</th></tr>";
				while($row = $result->fetch_assoc()) {
					echo "<tr><td>" . $row["IDMedicao"] . "</td><td>" . $row["Hora"] . "</td><td>" . $row["Leitura"] . "</td><td>".  $row["Sensor"] . "</tr>";
				}
				echo "</table>";
			} else {
				echo "Não foram encontrados resultados.";
			}

			// Fecha a conexão
			$conn->close();
		} else if(isset($_POST["submitMovimento"])) {

			// Obtém o valor inserido pelo usuário
			$idExperiencia = $_POST["idExperiencia"];

			$inteiro = intval($idExperiencia);

			// Consulta através de sql
			$sql = "CALL Mostra_Passagem('$inteiro');";
			$result = $conn->query($sql);

			// Se a consulta retornar resultados, mostrar numa tabela
			if ($result->num_rows > 0) {
				echo "<table>";
				echo "<tr><th>IDMedicao</th><th>Hora</th><th>Sala de entrada</th><th>Sala de saída</th></tr>";

   				while($row = $result->fetch_assoc()) {
	   				echo "<tr><td>" . $row["IdMedicao"] . "</td><td>" . $row["Hora"] . "</td><td>" . $row["SalaEntrada"] . "</td><td>".  $row["SalaSaida"] . "</tr>";
   				}
   				echo "</table>";
			} else {
   				echo "Não foram encontrados resultados.";
			}
		}else if(isset($_POST['logout'])) {
			session_unset();
			session_destroy();
			header('Location: loginPage.php');
			exit();
		}
	?>
</body>
</html>