package docker

approved_images := {
    "node:20-alpine",
    "cgr.dev/chainguard/",
    "gcr.io/distroless/"
}

deny contains msg if {
    some i
    input[i].Cmd == "from"

    image := input[i].Value[0]
    not approved_image(image)

    msg := sprintf(
        "Linha %d: imagem base '%s' não está aprovada.",
        [i + 1, image]
    )
}

approved_image(image) if {
    some approved in approved_images
    startswith(image, approved)
}