<!DOCTYPE html>
<html>
  <head>
    <title>Página de login</title>
    <link rel="stylesheet" type="text/css" href="style.css">
  </head>
  <body class="login">
    <div class="container">
      <h1>Comportamento dos ratos</h1>

      <form method="post" action="login.php">
        <label for="username">Nome de utilizador:</label>
        <input type="text" id="username" name="username">
        <label for="password">Password:</label>
        <input type="password" id="password" name="password">
        <input type="submit" value="Login">
      </form>
      <?php
      session_start(); // inicia a sessão
      if (isset($_SESSION["error"])) { // verifica se a variável de sessão existe
        echo "<p style='color:red'> Nome de utilizador ou password incorretos. Tente novamente. </p>"; // mostra a mensagem de erro em vermelho
        unset($_SESSION["error"]); // remove a variável de sessão
      }
    ?>
    </div>
  </body>
</html>

