const urlParams = new URLSearchParams(window.location.search);
const error = urlParams.get("error");

if (error === "invalid_login") {
  const errorMessage = document.createElement("p");
  errorMessage.innerText = "Usuário ou senha inválidos.";
  errorMessage.style.color = "red";
  document.body.appendChild(errorMessage);
}
