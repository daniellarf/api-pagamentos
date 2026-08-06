package main
deny[msg] {
  input[i].Cmd == "user"
  lower(input[i].Value[0]) == "root"
  msg := sprintf("Linha %d: USER root não é permitido.", [i])
}
deny[msg] {
  not has_user
  msg := "Dockerfile sem instrução USER."
}
has_user {
  input[_].Cmd == "user"
}