<!DOCTYPE html>
<html>

<?php
//Passa os dados da conexão da página anterior
session_start();
$servername = $_SESSION['servername'];
$username = $_SESSION['username'];
$password = $_SESSION['password'];
$dbname = $_SESSION['dbname'];
$name = $_SESSION['nome'];
$id = $_SESSION['id'];


?>

<title>Página de Experiência</title>
	<link rel="stylesheet" type="text/css" href="ratos.css">
</head>
<body>
<h1>Dados da experiênca Nº<?php echo $id?></h1>
	<form method="post">
		<input type="submit" name="submitExperiencias" value="Mostrar detalhes da experiência">
		<input type="submit" name="Voltar" value="Voltar">
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

            $sql = "CALL Mostra_Passagem('$id');";
            $result = $conn->query($sql);

			// Se a consulta retornar resultados, mostra numa tabela
			if ($result->num_rows > 0) {
			?>
			<h1>Tabela de Passagens</h1>
			<?php

				echo "<table>";
				echo "<tr><th>IDMedição</th><th>Hora</th><th>Sala de Entrada</th><th>SalaSaída</th></tr>";
				while($row = $result->fetch_assoc()) {
					echo "<tr><td>" . $row["IdMedicao"] . "</td><td>" . $row["Hora"] . "</td><td>" . $row["SalaEntrada"] . "</td><td>" . $row["SalaSaida"] . "</td>" . "</tr>";
				}
				echo "</table>";
			}else {
				echo"Não foram encontrados dados de passagens relativo a esta experiência";
			}


			while ($conn->next_result()) {
				if ($res = $conn->store_result()) {
					$res->free();
				}
			}


			$sql1 = "CALL Mostra_Odores('$id');";
            $result1 = $conn->query($sql1);
			if($result1->num_rows > 0){


			?>
            <h1>Tabela de Odores</h1>
            <?php
				echo "<table>";
                echo "<tr><th>Sala</th><th>CodigoOdor</th><th>Editar Odor</th></tr>";
                while($row1 = $result1->fetch_assoc()) {
					$idmedicao = intval($row1["IDMedicao"]);
                echo "<tr><td>" . $row1["Sala"] . "</td><td>" . $row1["CodigoOdor"] . "</td><td>
				<form method='post'><input type='hidden' name='editarOdor' value='$idmedicao'><input type='hidden' name='Editar Odor' value=Editar><input type='submit' name='Editar Odor' value=EditarOdor style='background-color: green;'></form></td></tr>";
                }
                echo "</table>";
			}else {
				echo"Não foram encontrados dados de odores relativo a esta experiência";
			}

			while ($conn->next_result()) {
				if ($res = $conn->store_result()) {
					$res->free();
				}
			}
			$sql2 = "CALL Mostra_Substancias('$id');";
            $result2 = $conn->query($sql2);

			if($result2->num_rows > 0){
            ?>

            <h1>Tabela de Substancias</h1>
            <?php
                echo "<table>";
                echo "<tr><th>NumeroRatos</th><th>CodigoSubstancia</th><th>Alterar valores</th></tr>";
                while($row = $result2->fetch_assoc()) {
					$idmedicao = intval($row["IDMedicao"]);
					echo "<tr><td>" . $row["NumeroRatos"] . "</td><td>" . $row["CodigoSubstancia"] . "</td><td><form method='post'><input type='hidden' name='editarSub' value='$idmedicao'><input type='hidden' name='Editar Substância' value=Editar><input type='submit' name='EditarSub' value=EditarSub style='background-color: green;'></form></td></tr>";

			}
               echo "</table>";
			}else {
				echo"Não foram encontrados dados de substâncias relativo a esta experiência";

			}
			while ($conn->next_result()) {
				if ($res = $conn->store_result()) {
					$res->free();
				}
			}
			$sql3 = "CALL Mostra_Alertas('$id');";
			$result3 = $conn->query($sql3);
			if($result3->num_rows > 0){

			?>
			<h1>Tabela de Alertas</h1>
            <?php
                echo "<table>";
                echo "<tr><th>Hora</th><th>Sala</th><th>Sensor</th><th>Leitura</th><th>Tipo de Alerta</th><th>Mensagem</th><th>Hora de escrita</th></tr>";
                while($row = $result3->fetch_assoc()) {
                echo "<tr><td>" . $row["Hora"] . "</td><td>" . $row["Sala"] . "</td><td>" . $row["Sensor"] . "</td><td>" . $row["Leitura"] . "</td><td>" . $row["TipoAlerta"] . "</td><td>" . $row["Mensagem"] . "</td><td>" . $row["horaescrita"] . "</td></tr>";
                }
               echo "</table>";
			} else {
				echo"Não foram encontrados alertas relativo a esta experiência";

			}

			while ($conn->next_result()) {
				if ($res = $conn->store_result()) {
					$res->free();
				}
			}
			$sql4 = "CALL Mostra_Salas('$id');";
			$result4 = $conn->query($sql4);
			if($result4->num_rows > 0){
				?>
				<h1>Tabela de Medições das Salas</h1>
				<?php
				echo "<table>";
				echo "<tr><th>Número de ratos na sala</th><th>Sala</th></tr>";
				while($row = $result3->fetch_assoc()) {
					echo"<tr><th>". $row["NumeroRatosFinal"]   . "</th><th>" .  $row["Sala"]  ."</th></tr>";
				}
				echo "</table>";
			} else {
				echo"Não foram encontrados alertas relativo a esta experiência";
			}




			// Fecha a conexão
			$conn->close();

			}else if(isset($_POST["Voltar"])) {

				$type = $conn->query("SELECT Mostra_Tipo_User('$username') AS tipo");
				$ro = $type->fetch_assoc();
				$tipo = $ro["tipo"];
				if ($tipo == 'ADM') {
					header("Location: homeADM.php");
				} elseif ($tipo == 'TEC') {
					header("Location: homeTEC.php");
				} elseif ($tipo == 'INV') {
					header("Location: homeINV.php");
				} else {
					throw new Exception("Ocorreu algum problema. Tenta novamente mais tarde.");
				}
                exit;


			}else if(isset($_POST["editarOdor"])) {
				$_SESSION['idmedicao'] = $_POST['editarOdor'];

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
					header("Location: alteraOdor.php");
				}else{
					echo "Esta experiência já foi iniciada e concluída";
				}



			}else if(isset($_POST["editarSub"])) {
				$_SESSION['idmedicao'] = $_POST['editarSub'];
				
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
					header("Location: alteraSubs.php");
				}else{
					echo "Esta experiência já foi iniciada e concluída";
				}


			}else if(isset($_POST["logout"])){
                session_unset();
                session_destroy();
                header('Location: loginPage.php');

                exit();
			}
?>
<html>