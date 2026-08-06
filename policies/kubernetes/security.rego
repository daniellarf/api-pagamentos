package kubernetes

deny contains msg if {
  input.kind == "Deployment"

  some container in input.spec.template.spec.containers
  not container.resources.limits.memory

  msg := sprintf(
    "Container '%s' deve definir limite de memória.",
    [container.name]
  )
}

deny contains msg if {
  input.kind == "Deployment"

  some container in input.spec.template.spec.containers
  not container.securityContext.runAsNonRoot

  msg := sprintf(
    "Container '%s' deve configurar runAsNonRoot como true.",
    [container.name]
  )
}