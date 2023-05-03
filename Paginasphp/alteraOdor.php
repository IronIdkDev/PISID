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
$idmedicao = $_SESSION['idmedicao'];

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
	die("Conexão falhou: " . $conn->connect_error);
}else{


// Nome da funntion
$function = "getLimiteSalas";
// Prepara a function
$stmt = $conn->prepare("SELECT $function(?) AS resultado");
// Define o valor do parâmetro da function
$stmt->bind_param('s',$id);
// Faz a consulta
$stmt->execute();
// Obtém o resultado da consulta
$result = $stmt->get_result();
// Guarda o valor retornado pela function
$resultado = $result->fetch_assoc()['resultado'];	
$resultadoSalas = intval($resultado);

}




?>



<title>Editar Odor </title>
	<link rel="stylesheet" type="text/css" href="ratos.css">
</head>

<body>

<h1>Editar Odor -> Total de salas: <?php echo "$resultadoSalas"; ?> </h1>
<?php
$sql1 = " CALL Return_Salas_Utilizadas('$id');";
$result1 = $conn->query($sql1);
			if($result1->num_rows > 0){
                echo"<table>";
echo"<tr><th>Salas ocupadas</th></tr>";
                while($row1 = $result1->fetch_assoc()) {
                    echo "<tr><td>" . $row1["Sala"] . "</td></tr>";
                }
echo"</table>";
            }


            while ($conn->next_result()) {
				if ($res = $conn->store_result()) {
					$res->free();
				}
			}
?>


<form method="post">

<input type="submit" name="delete" value="Apagar Odor">
<input type="submit" name="Voltar" value="Voltar">

</form>

<form method = "post">
<label for="sala">Número da Sala:</label>
<input type="number" name="sala" required>

<label for="odor">Código do Odor:</label>
<input type="text" name="odor" required>

<input type="submit" name="adicionar" value="adicionar">

</form>

</body>


<?php

		// Realizar a consulta
		if(isset($_POST["delete"])) {
            $sql = "CALL Delete_Sub('$idmedicao');";
            $result = $conn->query($sql);
            header("Location: detalhes.php");

        }else if(isset($_POST['adicionar'])) {


            $sala = $_POST['sala'];
            $odor = $_POST['odor'];




            if($sala > $resultadoSalas){
                echo"<script>alert(\"ERRO! O número inserido é superior ao permitido! Preencha novamente ou clique em Avançar\");</script>";

            }else {
                
                try {
                    $sql = "CALL Edita_Odor('$idmedicao', '$sala','$odor','$id')";
                    $result = $conn->query($sql);
                    header("Location: detalhes.php");
                
                } catch (Exception $e) {
                        echo $e->getMessage();
                    }
            }

        }else if(isset($_POST["Voltar"])) {
            header("Location: detalhes.php");
        }

        ?>
</html>