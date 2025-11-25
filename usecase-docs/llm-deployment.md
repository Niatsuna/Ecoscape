# LLM Deployment Use-case

The LLM deployment use-case includes a deployment of a kafka cluster, a prompt producer (load generator) and a LLM service (sut).

To run the scenario, please ensure that a `ecoscape-pvc` is present in the `load` and `sut` namespace with the following structure:

- Datasets in `/data` in the `load` namespace's pvc
- LLM in the `/models` in the `sut` namespace's pvc

For example deployment of such pvcs and corresponding preloader for easier propagation please look at [the example code of the corresponding master's thesis](https://github.com/Niatsuna/master-thesis/tree/main/ecoscape/llm-preloader/example).

The same project harbors the original code for the prompt producer and LLM service.

To run the scenario go to the `k8s/context.jsonnet` and specify the reference of the following file in the `config.json`:
`local config = import '../config/examples/llm-deployment.jsonnet';`

Before you build your scanrio add the `prefix` of your namespace in the file `config/context/cluster.json`

Then build the Kubernetes manifests with the `build` command.

Run the following commands step by step to get the full setup:

`deploy data/kafka`
`deploy data/kafka/topic`
`deploy data/kafka/ui`
`deploy infra/infra`
`deploy sut/original`
`deploy load/load`
