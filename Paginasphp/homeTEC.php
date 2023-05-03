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

	<link rel="stylesheet" type="text/css" href="ratos.css">
</head>

<body>
	<h1 class="titulo-principal">Bem-vindo <?php echo $name; ?></h1>

	<form method="post">
		<label for="idExperiencia">ID de Experiência:</label>
		<input type="number" name="idExperiencia" id="idExperiencia">
		<input type="submit" name="submitTemperatura" value="Mostrar medições de temperatura">
		<input type="submit" name="submitMovimento" value="Mostrar medições de movimento" onclick="limparFormulario()">
	</form>
	<script>
  // Função para limpar os dados do formulário
  function limparFormulario() {
    document.getElementById("idExperiencia").reset();
  }
</script>
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

		// Realizaa a consulta 
		if(isset($_POST["submitTemperatura"])) {
			
			//Se não for preenchido, irá mostrar todas as medições, caso seja colocado 0 mostra os dados que foram recolhidos durante o período sem experiências
			if (!empty($_POST['idExperiencia'] || $_POST['idExperiencia'] == 0)) {
				// Guarda o id experiência colocado no form
				$idExperiencia = $_POST["idExperiencia"];
				$inteiro = intval($idExperiencia);
			}else{
			// Transforma o valor inserido num int
			$inteiro = -1;
			}
			// Consulta através de sql
			$sql = "CALL Mostra_Medicoes_Temperatura('$inteiro');";
			$result = $conn->query($sql);

			// Se a consulta retornar resultados, mostra numa tabela
			if ($result->num_rows > 0) {
				echo "<table>";
				echo "<tr><th>IDMedicao</th><th>Hora</th><th>Leitura</th><th>Sensor</th></tr>";
				while($row = $result->fetch_assoc()) {
					echo "<tr><td>" . $row["IDMedicao"] . "</td><td>" . $row["Hora"] . "</td><td>" . $row["Leitura"] . "</td><td>".  $row["Sensor"] . "</tr>";
				}
				echo "</table>";
			} else {
				echo "Não foram encontradas medições de temperatura referentes a uma experiência.";
			}
		} else if(isset($_POST["submitMovimento"])) {

			//Se não for preenchido, irá mostrar todas as medições, caso seja colocado 0 mostra os dados que foram recolhidos durante o período sem experiências
			if (!empty($_POST['idExperiencia'] || $_POST['idExperiencia'] == 0)) {
				// Guarda o id experiência colocado no form
				$idExperiencia = $_POST["idExperiencia"];
				$inteiro = intval($idExperiencia);
			}else{
			// Transforma o valor inserido num int
			$inteiro = -1;
			}

			// Consulta através de sql
			$sql = "CALL Mostra_Passagem('$inteiro');";
			$result = $conn->query($sql);

			// Se a consulta retornar resultados, mostra numa tabela
			if ($result->num_rows > 0) {
				echo "<table>";
				echo "<tr><th>IDMedicao</th><th>Hora</th><th>Sala de entrada</th><th>Sala de saída</th></tr>";

   				while($row = $result->fetch_assoc()) {
	   				echo "<tr><td>" . $row["IdMedicao"] . "</td><td>" . $row["Hora"] . "</td><td>" . $row["SalaEntrada"] . "</td><td>".  $row["SalaSaida"] . "</tr>";
   				}
   				echo "</table>";
			} else {
   				echo "Não foram encontradas medições de movimento referentes a uma experiência";
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