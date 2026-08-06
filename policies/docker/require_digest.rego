package docker

deny contains msg if {
    some i
    input[i].Cmd == "from"

    image := input[i].Value[0]
    not contains(image, "@sha256:")

    msg := sprintf(
        "Linha %d: imagem base '%s' deve usar digest SHA256.",
        [i + 1, image]
    )
}