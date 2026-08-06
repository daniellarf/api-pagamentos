package docker

deny contains msg if {
    some i
    input[i].Cmd == "user"

    user := lower(input[i].Value[0])
    user == "root"

    msg := sprintf(
        "Linha %d: USER root não é permitido.",
        [i + 1]
    )
}

deny contains msg if {
    not has_user

    msg := "Dockerfile sem instrução USER."
}

has_user if {
    some i
    input[i].Cmd == "user"
}