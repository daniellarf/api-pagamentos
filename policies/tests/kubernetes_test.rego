package main

test_container_sem_limite_memoria_reprovado if {
  results := data.kubernetes.deny with input as {
    "kind": "Deployment",
    "spec": {
      "template": {
        "spec": {
          "containers": [
            {
              "name": "api",
              "securityContext": {
                "runAsNonRoot": true
              }
            }
          ]
        }
      }
    }
  }

  some m in results
  contains(m, "limite de memória")
}

test_container_root_reprovado if {
  results := data.kubernetes.deny with input as {
    "kind": "Deployment",
    "spec": {
      "template": {
        "spec": {
          "containers": [
            {
              "name": "api",
              "resources": {
                "limits": {
                  "memory": "256Mi"
                }
              }
            }
          ]
        }
      }
    }
  }

  some m in results
  contains(m, "runAsNonRoot")
}

test_deployment_conforme_aprovado if {
  results := data.kubernetes.deny with input as {
    "kind": "Deployment",
    "spec": {
      "template": {
        "spec": {
          "containers": [
            {
              "name": "api",
              "securityContext": {
                "runAsNonRoot": true
              },
              "resources": {
                "limits": {
                  "memory": "256Mi"
                }
              }
            }
          ]
        }
      }
    }
  }

  count(results) == 0
}