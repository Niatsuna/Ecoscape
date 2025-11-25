function(
  name,
  definition={
    locationLabel: "node1",
    memory: "4Gi",
    cpu: "2",
    replicas: 1,
    gpuMode: false,
    outputTopic: "reporter",
    modelPath: ""
  },
  externalParameters={
    bootstrapServer: "",
    topic: "input",
    namespace: "sut"
  }
) {
  apiVersion: "apps/v1",
  kind: "Deployment",
  metadata: {
    name: name,
    namespace: externalParameters.namespace
  },
  spec: {
    replicas: definition.replicas,
    selector: {
      matchLabels: {
        app: name,
        "ecoscape/node": definition.locationLabel
      }
    },
    template: {
      metadata: {
        labels: {
          app: name,
          "ecoscape/node": definition.locationLabel
        }
      },
      spec: {
        containers: [
          {
            name: name,
            image: (if definition.gpuMode then "niatsuna/llm-prompt-sut:gpu" else "niatsuna/llm-prompt-sut:cpu"),
            imagePullPolicy: "Always",
            env: [
              {
                name: "BOOTSTRAP_SERVER",
                value: externalParameters.bootstrapServer(definition.kafkaCluster)
              },
              {
                name: "INPUT_TOPIC",
                value: externalParameters.topic
              },
              {
                name: "OUTPUT_TOPIC",
                value: definition.outputTopic
              },
              {
                name: "MODEL_PATH",
                value: definition.modelPath
              },
              {
                name: "METRICS_PORT",
                value: "5000"
              },
              {
                name: "NODE_ID",
                value: name
              }
            ],
            ports: [
              {
                containerPort: 80,
                name: "web"
              },
              {
                containerPort: 5000,
                name: "metrics"
              }
            ],
            resources: {
              limits: {
                cpu: definition.cpu,
                memory: definition.memory
              },
              requests: {
                cpu: definition.cpu,
                memory: definition.memory
              }
            },
            volumeMounts: [
              {
                name: definition.pvcName,
                mountPath: "/models",
                readOnly: true
              }
            ]
          }
        ],
        volumes: [
          {
            name: definition.pvcName,
            persistentVolumeClaim: {
              claimName: definition.pvcName
            }
          }
        ]
      }
    }
  }
}