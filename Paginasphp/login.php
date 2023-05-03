<?php

$user = $_POST["username"];
$pass = $_POST["password"];

// Informações de conexão com a base de dados
$servername = "localhost";
$username = $user;
$password = $pass;
$dbname = "pisid";

try {
  // Cria a conexão
  $conn = new mysqli($servername, $username, $password, $dbname);

  // Verifica a conexão
  if ($conn->connect_error) {
      throw new Exception("Utilizador ou password incorretos.");
  }

  $nome = $conn->query("SELECT UserName('$user') AS nome");      
  $ro = $nome->fetch_assoc();
  $name = strval($ro['nome']);
  
  session_start();
  $_SESSION['servername'] = $servername;
  $_SESSION['username'] = $username;
  $_SESSION['password'] = $password;
  $_SESSION['dbname'] = $dbname;
  $_SESSION['nome'] = $name;

 // Consulta a base de dados para verificar se o utilizador está correto
 $sql = "CALL Mostrar_User('$user');";
 $result = $conn->query($sql) or die(mysqli_error($conn));
 

// Verifica se a consulta retornou algum resultado
if ($result->num_rows == 1 ) {
    $row = $result->fetch_assoc();

    // Verifica o tipo do utilizador. Dependendo do tipo, vai para uma página diferente
    if ($conn->next_result()) {
        $type = $conn->query("SELECT Mostra_Tipo_User('$user') AS tipo");
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
    }
} else {
    // Se o utilizador não existir, mostra uma mensagem de erro
    throw new Exception("Utilizador não existe!");
}

  // Termina a conexão
  $conn->close();
} catch (Exception $e) {
  // Exibe uma mensagem de erro personalizada e redireciona para a página de login
  session_start();
  $_SESSION["error"] = $e->getMessage();
  header("Location: loginPage.php");
  exit();
}


?>


