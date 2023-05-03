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

			// Se a consulta retornar resultados, mostra numa tabela
			if ($result->num_rows > 0) {
				echo "<table>";
				echo "<tr><th>IDExperiência</th><th>Descrição</th><th>Data e Hora</th><th>Número de Ratos</th><th>Limite de Ratos por Sala</th><th>Segundos sem movimento</th><th>Temperatura Ideal</th><th>Variação Máxima da Temperatura </th><th>Ativa(1=Sim, 0 = Não)</th><th>Detalhes da experiência</th></tr>";
				while($row = $result->fetch_assoc()) {
					$id = intval($row["IDexperiência"]);
					echo "<tr><td>" . $row["IDexperiência"] . "</td><td>" . $row["Descricao"] . "</td><td>".  $row["DataHora"] . "</td><td>" . $row["NumeroRatos"] . "</td><td>" . $row["LimiteRatosSala"] . "</td><td>" . $row["SegundosSemMovimento"] . "</td><td>" . $row["TemperaturaIdeal"] . "</td><td>" . $row["VariacaoTemperaturaMaxima"] . "</td><td>" . $row["Ativa"] . "</td><td><form method='post'><input type='hidden' name='detalhes' value='$id'><input type='hidden' name='Detalhes' value=Detalhes><input type='submit' name='mostraDetalhes' value=Detalhes style='background-color: green;'></form></td></tr>";
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
			
			// Se a consulta retornar resultados, mostra numa tabela
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




		//Termina a sessão do utilizador	
		}else if(isset($_POST['logout'])) {
			session_unset();
			session_destroy();
			header('Location: loginPage.php');
			exit();
		//Muda o estado do utilizador selecionado	
		}else if(isset($_POST["submitEstado"])) {
			$emailUtilizador = $_POST["emailUtilizador"];
			$sql = "CALL Suspend_User('$emailUtilizador');";
			$result = $conn->query($sql);

		
		//Permite criar um novo utilizador
		}else if (isset($_POST["formulario"])) {
			$nome = $_POST["nome"];
			$pass = $_POST["password"];
			$email = $_POST["email"];
			$telefone = $_POST["telefone"];
			$tipo = $_POST["tipo"];

			//Conjunto de verificações que, dependendo do tipo do utilizador, são lhe dadas privilégios diferentes
			if (isset($tipo) && $tipo === "ADM") {
				$sql = "CALL criar_Utilizador('$nome','$telefone','$tipo','$email')";
				$result = $conn->query($sql);

					// Cria a conexão
					$conn2 = new mysqli($servername, $username, $password, "");
					if ($conn2->connect_error) {
						die("Conexão falhou: " . $conn2->connect_error);
					}

					//Conjunto de privilégios dados aos utilizadores ADM	
					$sql1 = "CREATE USER '$email'@'%' IDENTIFIED BY '$pass';";
					$sql2 = "GRANT ALL PRIVILEGES ON *.* TO '$email'@'%' WITH GRANT OPTION;"; 
					$sql4 = "GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Criar_Utilizador` TO '$email'@'%' WITH GRANT OPTION;";
					$sql5 = "GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Mostrar_Outros_Users` TO '$email'@'%' WITH GRANT OPTION;";
					$sql6 ="GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Mostra_Substancias` TO '$email'@'%' WITH GRANT OPTION;";
					$sql7 ="GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Mostra_Passagem` TO '$email'@'%' WITH GRANT OPTION;";
					$sql8 ="GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Mostra_Odores` TO '$email'@'%' WITH GRANT OPTION;";
					$sql9 ="GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Mostra_Medicoes_Temperatura` TO '$email'@'%' WITH GRANT OPTION;";
					$sql10 ="GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Mostrar_User` TO '$email'@'%' WITH GRANT OPTION;";
					$sql11 = "GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Mostra_Experiencia` TO '$email'@'%' WITH GRANT OPTION;";
					$sql12 = "GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Suspend_User` TO '$email'@'%' WITH GRANT OPTION;";
					$sql13 = "GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Mostra_Alertas` TO '$email'@'%' WITH GRANT OPTION;";
					$sql13a = "GRANT ALTER ROUTINE, EXECUTE ON FUNCTION `pisid`.`Mostra_Tipo_User` TO '$email'@'%' WITH GRANT OPTION;";
					$sql14 = "GRANT SELECT ON pisid.alerta TO '$email'@'%' WITH GRANT OPTION;";
					$sql15 = "GRANT SELECT ON pisid.experiencia TO '$email'@'%' WITH GRANT OPTION;";
					$sql16 = "GRANT SELECT ON pisid.medicoespassagens TO '$email'@'%' WITH GRANT OPTION;";
					$sql17 = "GRANT SELECT ON pisid.medicoessalas TO '$email'@'%' WITH GRANT OPTION;";
					$sql18 = "GRANT SELECT ON pisid.medicoestemperatura TO '$email'@'%' WITH GRANT OPTION;";
					$sql19 = "GRANT SELECT ON pisid.odoresexperiencia TO '$email'@'%' WITH GRANT OPTION;";
					$sql20 = "GRANT SELECT ON pisid.substanciaexperiencia TO '$email'@'%' WITH GRANT OPTION;";
					$sql21 = "GRANT SELECT ON pisid.utilizador TO '$email'@'%' WITH GRANT OPTION;";
					$sql22 = "REVOKE ALL PRIVILEGES ON *.* FROM '$email'@'%';";
					$sql23 = "GRANT ALL PRIVILEGES ON *.* TO '$email'@'%' REQUIRE NONE WITH GRANT OPTION MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;";

					$conn2->query($sql1);
					$conn2->query($sql2);
					$conn2->query($sql4);
					$conn2->query($sql5);
					$conn2->query($sql6);
					$conn2->query($sql7);
					$conn2->query($sql8);
					$conn2->query($sql9);
					$conn2->query($sql10);
					$conn2->query($sql11);
					$conn2->query($sql12);
					$conn2->query($sql13);
					$conn2->query($sql13a);
					$conn2->query($sql14);
					$conn2->query($sql15);
					$conn2->query($sql16);
					$conn2->query($sql17);
					$conn2->query($sql18);
					$conn2->query($sql19);
					$conn2->query($sql20);
					$conn2->query($sql21);
					$conn2->query($sql22);
					$conn->query($sql23);
		

		
			}else if (isset($tipo) && $tipo === "INV") {

				$sql = "CALL criar_Utilizador('$nome','$telefone','$tipo','$email')";
				$result = $conn->query($sql);

				$conn2 = new mysqli($servername, $username, $password, "");

				//Privilégios dados aos INV
				$sql1 = "CREATE USER '$email'@'%' IDENTIFIED BY '$pass';";
				$sql2 = "GRANT SELECT, INSERT, UPDATE, CREATE, ALTER, SHOW DATABASES, CREATE VIEW, EVENT, TRIGGER, SHOW VIEW, ALTER ROUTINE, EXECUTE ON *.* TO '$email'@'%'";
				
				$sql3 ="GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Criar_Experiencia` TO '$email'@'%' WITH GRANT OPTION;";
				$sql4 ="GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Cria_Subs` TO '$email'@'%' WITH GRANT OPTION;";
				$sql5 ="GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Cria_Odor` TO '$email'@'%' WITH GRANT OPTION;";
				
				$sql6 ="GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Mostra_Substancias` TO '$email'@'%' WITH GRANT OPTION;";
				$sql7 ="GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Mostra_Passagem` TO '$email'@'%' WITH GRANT OPTION;";
				$sql8 ="GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Mostra_Odores` TO '$email'@'%' WITH GRANT OPTION;";
				$sql9 ="GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Mostra_Medicoes_Temperatura` TO '$email'@'%' WITH GRANT OPTION;";
				$sql10 = "GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Mostra_Experiencia` TO '$email'@'%' WITH GRANT OPTION;";
				$sql11 = "GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Mostra_Alertas` TO '$email'@'%' WITH GRANT OPTION;";
				$sql12a = "GRANT ALTER ROUTINE, EXECUTE ON FUNCTION `pisid`.`getSalas` TO '$email'@'%' WITH GRANT OPTION;";
				$sql12b = "GRANT ALTER ROUTINE, EXECUTE ON FUNCTION `pisid`.`getLastExperiencia` TO '$email'@'%';";
				$sql12c = "GRANT ALTER ROUTINE, EXECUTE ON FUNCTION `pisid`.`getSumRats` TO '$email'@'%';";
				$sql12d = "GRANT ALTER ROUTINE, EXECUTE ON FUNCTION `pisid`.`getNumSalas` TO '$email'@'%';";
				$sql12e = "GRANT ALTER ROUTINE, EXECUTE ON FUNCTION `pisid`.`verifyExperiencia` TO '$email'@'%';";
				
				$sql12f = "GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Mostra_Odores` TO '$email'@'%';";
				$sql12h = "GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Mostra_Salas` TO '$email'@'%';";
				$sql12i = "GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Delete_Odor` TO '$email'@'%';";
				$sql12j = "GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Delete_Sub` TO '$email'@'%';";
				$sql12k = "GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Edita_Odor` TO '$email'@'%';";
				$sql12l = "GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Editar_Sub` TO '$email'@'%';"; 
				$sql12m = "GRANT ALTER ROUTINE, EXECUTE ON FUNCTION `pisid`.`getLimiteSalas` TO '$email'@'%';";

				$sql12 = "GRANT SELECT ON pisid.alerta TO '$email'@'%' WITH GRANT OPTION;";
				$sql13 = "GRANT SELECT ON pisid.experiencia TO '$email'@'%' WITH GRANT OPTION;";
				$sql14 = "GRANT SELECT ON pisid.medicoespassagens TO '$email'@'%' WITH GRANT OPTION;";
				$sql15 = "GRANT SELECT ON pisid.medicoessalas TO '$email'@'%' WITH GRANT OPTION;";
				$sql16 = "GRANT SELECT ON pisid.medicoestemperatura TO '$email'@'%' WITH GRANT OPTION;";
				$sql17 = "GRANT SELECT ON pisid.odoresexperiencia TO '$email'@'%' WITH GRANT OPTION;";
				$sql18 = "GRANT SELECT ON pisid.substanciaexperiencia TO '$email'@'%' WITH GRANT OPTION;";


				$conn2->query($sql1);
				$conn2->query($sql2);
				$conn2->query($sql3);
				$conn2->query($sql4);
				$conn2->query($sql5);
				$conn2->query($sql6);
				$conn2->query($sql7);
				$conn2->query($sql8);
				$conn2->query($sql9);
				$conn2->query($sql10);
				$conn2->query($sql11);
				$conn2->query($sql12);
				$conn2->query($sql12a);
				$conn2->query($sql12b);
				$conn2->query($sql12c);
				$conn2->query($sql12d);
				$conn2->query($sql12e);
				$conn2->query($sql12f);
				$conn2->query($sql12h);
				$conn2->query($sql12i);
				$conn2->query($sql12j);
				$conn2->query($sql12k);
				$conn2->query($sql12l);
				$conn2->query($sql12m);
				$conn2->query($sql13);
				$conn2->query($sql14);
				$conn2->query($sql15);
				$conn2->query($sql16);
				$conn2->query($sql17);
				$conn2->query($sql18);

			}else if (isset($tipo) && $tipo === "TEC") {

				$sql = "CALL criar_Utilizador('$nome','$telefone','$tipo','$email')";
				$result = $conn->query($sql);

				$conn2 = new mysqli($servername, $username, $password, "");

				//Privilégios dados aos TEC
				$sql1 = "CREATE USER '$email'@'%' IDENTIFIED BY '$pass';";
				$sql2 = "GRANT SELECT, INSERT, UPDATE, CREATE, ALTER, SHOW DATABASES, CREATE VIEW, EVENT, TRIGGER, SHOW VIEW, ALTER ROUTINE, EXECUTE ON *.* TO '$email'@'%'";

				$sql6 ="GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Mostra_Substancias` TO '$email'@'%' WITH GRANT OPTION;";
				$sql7 ="GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Mostra_Passagem` TO '$email'@'%' WITH GRANT OPTION;";
				$sql8 ="GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Mostra_Odores` TO '$email'@'%' WITH GRANT OPTION;";
				$sql9 ="GRANT ALTER ROUTINE, EXECUTE ON PROCEDURE `pisid`.`Mostra_Medicoes_Temperatura` TO '$email'@'%' WITH GRANT OPTION;";


				$sql13 = "GRANT SELECT ON pisid.alerta TO '$email'@'%' WITH GRANT OPTION;";
				$sql14 = "GRANT SELECT ON pisid.experiencia TO '$email'@'%' WITH GRANT OPTION;";
				$sql15 = "GRANT SELECT ON pisid.medicoespassagens TO '$email'@'%' WITH GRANT OPTION;";
				$sql16 = "GRANT SELECT ON pisid.medicoessalas TO '$email'@'%' WITH GRANT OPTION;";
				$sql17 = "GRANT SELECT ON pisid.medicoestemperatura TO '$email'@'%' WITH GRANT OPTION;";
				$sql18 = "GRANT SELECT ON pisid.odoresexperiencia TO '$email'@'%' WITH GRANT OPTION;";
				$sql19 = "GRANT SELECT ON pisid.substanciaexperiencia TO '$email'@'%' WITH GRANT OPTION;";



				
				$conn2->query($sql1);
				$conn2->query($sql2);
				$conn2->query($sql6);
				$conn2->query($sql7);
				$conn2->query($sql8);
				$conn2->query($sql9);
				$conn2->query($sql13);
				$conn2->query($sql14);
				$conn2->query($sql15);
				$conn2->query($sql16);
				$conn2->query($sql17);
				$conn2->query($sql18);
				$conn2->query($sql19);

			}
			
			
			$conn2->close();
		//Leva à página de detalhes de uma experiência	
		}else if(isset($_POST['detalhes'])){
			$id = $_POST['detalhes'];
			session_start();
			$_SESSION['id'] = $_POST['detalhes'];
			header("Location: detalhes.php");

	}
		?>
</body>
</html>
