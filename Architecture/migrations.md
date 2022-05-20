# Migration sequence

1. Add logic at consumers side to receive new message
    - create new logic class (e.g. processor, upserter etc.)
    - update worker to switch on message version to right logic class
    - options is to process only one version (and ack others) or all
2. Migrate consumers DB
3. Make Version+1 schema for new messages
4. Migrate DB at producer side
5. Add logic at producer to send V+1 message
6. Add V+1 messages to producer
    - if all consumers were switched to V+1, then remove previous version
7. Send new messages, wait some time for all previous version message to be processed
8. Remove previous version message logic from consumers 