function(
  name,
  index=0,
  definition={
    location: "",
    baseRPS: "0.2",
    loadPattern: "poisson",
    pvcName: "ecoscape-pvc",
    datasetPath: "",
  },
  externalParameters={
    bootstrapServer: "",
    inputTopic: "input",
    namespace: "load",
  }
) {
  apiVersion: "apps/v1",
  kind: "Deployment",
  metadata: {
    name: name,
    namespace: externalParameters.namespace
  },
  spec: {
    selector: {
      matchLabels: {
        "ecoscape/node": definition.location
      }
    },
    replicas: 1,
    template: {
      metadata: {
        labels: {
          "ecoscape/node": definition.location
        }
      },
      spec: {
        nodeSelector: {
          "kubernetes.io/hostname": definition.location
        },
        containers: [
          {
            name: name,
            image: "niatsuna/llm-promp-producer:latest",
            imagePullPolicy: "IfNotPresent",
            env: [
              {
                name: "KAFKA_BOOTSTRAP_SERVERS",
                value: externalParameters.bootstrapServer(definition.kafkaCluster)
              },
              {
                name: "KAFKA_TOPIC",
                value: externalParameters.inputTopic
              },
              {
                name: "DATASET_PATH",
                value: definition.datasetPath
              },
              {
                name: "METRICS_PORT",
                value: 5000
              },
              {
                name: "BASE_RPS",
                value: std.toString(definition.baseRPS)
              },
              {
                name: "LOAD_PATTERN",
                value: definition.loadPattern
              }
            ],
            ports: [
              {
                containerPort: 80,
                name: "web"
              }
            ],
            resources: {
              limits: {
                cpu: "2",
                memory: "4Gi"
              },
              requests: {
                cpu: "2",
                memory: "4Gi"
              }
            },
            volumeMounts: [
              {
                name: definition.pvcName,
                mountPath: "/data",
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