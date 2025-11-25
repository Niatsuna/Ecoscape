local kafkaTopic = import '../kafka/kafka-topic.jsonnet';
local imageProducer = import 'image-producer.jsonnet';
local loadRegistry = import 'load-registry.jsonnet';
local promptProducer = import 'prompt-producer.jsonnet';

function(context, path="load", key="load") (
    local loadConfig = std.get(context.config.load, key);
    std.get(loadRegistry(context), loadConfig.loadType)(path, loadConfig)
)