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

	<title>Página de Investigador</title>
    	<link rel="stylesheet" type="text/css" href="ratos.css">
    </head>
    <body>
    <h1>Bem-vindo <?php echo $name; ?></h1>
    	<form method="post">
    		<input type="submit" name="submitExperiencias" value="Mostrar as experiências">
    		<input type="submit" name="submitCriarExperiencias" value="Criar Experiência">
    		<input type="submit" name="logout" value="Logout">
    	</form>

    <?php
if(empty($username) || empty($password)){
    header("Location: erro.php");
}
// Cria a conexão
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



    		// Realiza a consulta
    		if(isset($_POST["submitExperiencias"])) {

    			// Consulta através de sql
    			$sql = "CALL Mostra_Experiencia('$username');";
    			$result = $conn->query($sql);

    			// Se a consulta retornar resultados, mostra numa tabela
    			if ($result->num_rows > 0) {
    				echo "<table>";
    				echo "<tr><th>IDExperiência</th><th>Descrição</th><th>Data e Hora</th><th>Número de Ratos</th><th>Limite de Ratos por Sala</th><th>Segundos sem movimento</th><th>Temperatura Ideal</th><th>Variação Máxima da Temperatura </th><th>Ativa(1=Sim, 0 = Não)</th><th>Começa/Termina Experiência</th><th>Detalhes</th><th>Editar Descrição</th></tr>";
    				while($row = $result->fetch_assoc()) {
					$id = intval($row["IDexperiência"]);
					$estado = intval($row["Ativa"]);
					if ($estado == 2) {
						$acao = "Terminar Experiência";
					} else if($estado == 0){
						$acao = "Começar Experiência";
					}else if($estado == 1){
						$acao = "Experiência em espera";
					}
    					echo "<tr><td>" . $row["IDexperiência"] . "</td><td>" . $row["Descricao"] . "</td><td>".  $row["DataHora"] . "</td><td>" . $row["NumeroRatos"] . "</td><td>" . $row["LimiteRatosSala"] . "</td><td>" . $row["SegundosSemMovimento"] . "</td><td>" . $row["TemperaturaIdeal"] . "</td><td>" . $row["VariacaoTemperaturaMaxima"] . "</td><td>" . $row["Ativa"] . "</td><td>  <form method='post'><input type='hidden' name='alteraEstado' value='$id'><input type='hidden' name='estado' value='$estado'><input type='submit' name='acaoAlteraEstado' value='$acao' style='background-color: red;'></form></td><td><form method='post'><input type='hidden' name='detalhes' value='$id'><input type='hidden' name='Detalhes' value=Detalhes><input type='submit' name='mostraDetalhes' value=Detalhes style='background-color: green;'></form></td><td><form method='post'><input type='hidden' name='editar' value='$id'><input type='hidden' name='Editar' value=Editar><input type='submit' name='mostraEditar' value=Editar style='background-color: green;'></form></td></tr>";
    				}
    				echo "</table>";
    			} else {
    				echo "Não foram encontrados resultados.";
    			}

    			// Fecha a conexão
    			$conn->close();
    		}else if(isset($_POST["submitCriarExperiencias"])) {

    ?>
                <form method="post">
				<label for="descrição">Descrição:</label>
                <input type="text" name="descricao" id="descrição" maxlength="100" required>

				<label for="numeroRatos">Número de ratos:</label>
                <input type="number" name="numeroRatos" required>

                <label for="limiteRatosSala">Limite de ratos por sala:</label>
                <input type="number" name="limiteRatosSala" required>

                <label for="SegundosSemMovimento">Segundos sem movimentos:</label>
                <input type="number" name="segundosSemMovimento" required>

                <label for="TemperaturaIdeal">Temperatura ideal:</label>
                <input type="number" name="temperaturaIdeal" required>

                <label for="VariacaoTemperaturaMaximadeTempMaxima">Variação de temperatura máxima:</label>
                <input type="number" name="variacaoTemperaturaMaxima" required>

                <br><br><input type="submit" name= "experiencia" value="Adicionar experiência">
			    </form>

    <?php
	//Se clicar em logout a conexão é terminada
            }else if(isset($_POST['logout'])) {
            			session_unset();
            			session_destroy();
            			header('Location: loginPage.php');
            			exit();
			//Altera o estado da experiência			
            }else if(isset($_POST['alteraEstado'])){
				$id = $_POST['alteraEstado'];
				$sql = "CALL AtualizaExperiencia('$id');";
				try {
				
				$result = $conn->query($sql);
				$_SESSION['id'] = $_POST['alteraEstado'];
			} catch (mysqli_sql_exception $e) {
				echo '<h1 style="color: red;">Erro ao atualizar a experiência: ' . $e->getMessage() . '</h1>';
			}
			//Mostra os detalhes de uma experiência	
			}else if(isset($_POST['detalhes'])){
				$id = $_POST['detalhes'];
				session_start();
				$_SESSION['id'] = $_POST['detalhes'];
				header("Location: detalhes.php");

			//Trata da criação da experiência através das informações dadas no form			
			}else if(isset($_POST['experiencia'])){
				$descricao =  $_POST['descricao'];
				$numeroRatos =  $_POST['numeroRatos'];
				$limiteRatos =  $_POST['limiteRatosSala'];
				$segundosSemMovimento =  $_POST['segundosSemMovimento'];
				$temperaturaIdeal =  $_POST['temperaturaIdeal'];
				$variacaoTemperaturaMaxima =  $_POST['variacaoTemperaturaMaxima'];
				$_SESSION['numeroRatos'] = $_POST['numeroRatos'];

				$sql = "CALL Criar_Experiencia('$descricao','$username', '$numeroRatos', '$limiteRatos', '$segundosSemMovimento', '$temperaturaIdeal', '$variacaoTemperaturaMaxima');";
				$conn->query($sql);
				header("Location: ratos.php");	


			//Permite editar a experiência (Descrição)	
			}else if(isset($_POST['editar'])){

				$id = $_POST['editar'];
				$_SESSION['id'] = $_POST['editar'];

				// Nome da funntion
				$function = "verifyExperiencia";
				// Prepara a function
				$stmt = $conn->prepare("SELECT $function(?) AS resultado");
				// Define o valor do parâmetro da function
				$stmt->bind_param('s', $id);
				// Faz a consulta
				$stmt->execute();
				// Obtém o resultado da consulta
				$result = $stmt->get_result();
				// Guarda o valor retornado pela function
				$resultado = $result->fetch_assoc()['resultado'];	
				$resultadoInt = intval($resultado);
				if($resultadoInt == 0){
					header("Location: descricao.php");
				}else{
					echo "Esta experiência já foi iniciada e concluída";
				}
			}
    ?>

</body>
</html>