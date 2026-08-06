package main
import future.keywords.if

deny[msg] if {
  input[i].Cmd == "user"
  lower(input[i].Value[0]) == "root"
  msg := sprintf("Linha %d: USER root não é permitido.", [i])
}

deny[msg] if {
  not has_user
  msg := "Dockerfile sem instrução USER."
}

has_user if {
  some i
  input[i].Cmd == "user"
}
