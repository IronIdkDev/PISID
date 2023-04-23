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

	<title>Página de ADM</title>
	<!-- Inclui o ficheiro CSS para o tema de Ratos -->
	<link rel="stylesheet" type="text/css" href="ratos.css">
</head>
<body>
<h1>Bem-vindo <?php echo $name; ?></h1>
	<form method="post">
		<input type="submit" name="submitExperiencias" value="Mostrar todas as experiências">
		<input type="submit" name="submitUsers" value="Mostrar todos os Utilizadores">
		<input type="submit" name="submitCriarUsers" value="Criar um user">
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
		if(isset($_POST["submitExperiencias"])) {

			// Consulta através de sql
			$sql = "SELECT * FROM experiencia;";
			$result = $conn->query($sql);

			// Se a consulta retornar resultados, mostrar numa tabela
			if ($result->num_rows > 0) {
				echo "<table>";
				echo "<tr><th>IDExperiência</th><th>Descrição</th><th>Data e Hora</th><th>Número de Ratos</th><th>Limite de Ratos por Sala</th><th>Segundos sem movimento</th><th>Temperatura Ideal</th><th>Variação Máxima da Temperatura </th><th>Ativa(1=Sim, 0 = Não)</th></tr>";
				while($row = $result->fetch_assoc()) {
					echo "<tr><td>" . $row["IDexperiência"] . "</td><td>" . $row["Descricao"] . "</td><td>".  $row["DataHora"] . "</td><td>" . $row["NumeroRatos"] . "</td><td>" . $row["LimiteRatosSala"] . "</td><td>" . $row["SegundosSemMovimento"] . "</td><td>" . $row["TemperaturaIdeal"] . "</td><td>" . $row["VariacaoTemperaturaMaxima"] . "</td><td>" . $row["Ativa"] . "</tr>";
				}
				echo "</table>";
			} else {
				echo "Não foram encontrados resultados.";
			}

			// Fecha a conexão
			$conn->close();
		}else if(isset($_POST["submitUsers"])) {
			$sql = "CALL Mostrar_Outros_Users('$username')";
			$result = $conn->query($sql);
			
			// Se a consulta retornar resultados, mostrar numa tabela
			if ($result->num_rows > 0) {
				echo "<table>";
				echo "<tr><th>Nome </th><th>Email</th><th>Número de Telefone</th><th>Tipo de utilizador</th><th>Ativo(1=Sim, 0 = Não)</th><th>Desativar/Ativar utilizador</th><th>Ver perfil</th></tr>";
				while($row = $result->fetch_assoc()) {
					// Botão para banir/desbanir utilizador
					$emailUtilizador = $row["EmailUtilizador"]; // guardar o email do utilizador
					$estado = intval($row["Ativo"]); // guardar o estado atual do utilizador
					if ($estado == 1) {
						$acao = "Banir Utilizador";
					} else {
						$acao = "Desbanir Utilizador";
					}
					echo "<tr><td>" . $row["NomeUtilizador"] . "</td><td>" . $row["EmailUtilizador"] . "</td><td>" . $row["TelefoneUtilizador"] . "</td><td>" . $row["TipoUtilizador"] . "</td><td>" . $row["Ativo"] . "</td><td><form method='post'><input type='hidden' name='emailUtilizador' value='$emailUtilizador'><input type='hidden' name='estado' value='$estado'><input type='submit' name='submitEstado' value='$acao' style='background-color: red;'></form></td><td><a href='perfilUser.php'>Perfil do usuário</a></td></tr>";
				}
				echo "</table>";
			} else {
				echo "Não foram encontrados resultados.";
			}
		}else if(isset($_POST["submitCriarUsers"])) {
			
			?>	

			<form method="post">
				<label for="nome">Nome:</label>
				<input type="text" name="nome" id="nome" maxlength="100" required>
				<label for="password">Password</label>
				<input type="password" name="password" id="password" maxlength="100" required> 
				<label for="email">Email:</label>
				<input type="text" name="email" id="email" maxlength="50" requires>
				<label for="telefone">Telefone:</label>
				<input type="tel" id="telefone" name="telefone" required>
				<label for="tipo">Tipo de utilizador</label>
				<select name="tipo" required>
					<option value="TEC">TEC</option>
					<option value="ADM">ADM</option>
					<option value="INV">INV</option>
				</select>
				<br><br><input type="submit" name= "formulario" value="Submeter">
			</form>
<?php





		}else if(isset($_POST['logout'])) {
			session_unset();
			session_destroy();
			header('Location: loginPage.php');

			exit();
		}else if(isset($_POST["submitEstado"])) {
			$emailUtilizador = $_POST["emailUtilizador"];
			$sql = "CALL Suspend_User('$emailUtilizador');";
			$result = $conn->query($sql);

		
		
		}else if (isset($_POST["formulario"])) {
			echo "ENTREI NO IF ";
			$nome = $_POST["nome"];
			$password = $_POST["password"];
			$email = $_POST["email"];
			$telefone = $_POST["telefone"];
			$tipo = $_POST["tipo"];

			
			if (isset($tipo) && $tipo === "INV") {
				echo "Criaste um inventor";
				$sql = "CALL criar_Utilizador('$nome','$telefone','$tipo','$email')";
				$result = $conn->query($sql);
		
			}else if (isset($tipo) && $tipo === "ADM") {
				echo "criaste um adm";
				// faça algo se $tipo for "INV"
			}else if (isset($tipo) && $tipo === "TEC") {
				// faça algo se $tipo for "INV"
				echo "criaste um tec";
			}
			
			
			
		
		
		
		}
		?>
</body>
</html>
