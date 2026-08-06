package docker

deny contains msg if {
    not has_healthcheck

    msg := "Dockerfile deve possuir instrução HEALTHCHECK."
}

has_healthcheck if {
    some i
    input[i].Cmd == "healthcheck"
}