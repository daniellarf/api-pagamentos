package docker

deny contains msg if {
    not has_license_label

    msg := "Dockerfile deve definir LABEL org.opencontainers.image.licenses."
}

has_license_label if {
    some i
    input[i].Cmd == "label"

    some value in input[i].Value
    contains(lower(sprintf("%v", [value])), "org.opencontainers.image.licenses")
}