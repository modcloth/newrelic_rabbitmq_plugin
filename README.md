## New Relic RabbitMQ Plugin

This plugin reports statistics from RabbitMQ to NewRelic such as:

- Message rates
- Queue size
- Resource usage (by node)


### Requirements

The monitiored RabbitMQ instances must be running the management
plugin so that the HTTP API is exposed.

### Installing

`sudo gem install newrelic_rabbitmq_plugin`

### Configuring

Create a `newrelic_plugin.yml` file using `config/template_newrelic_plugin.yml` as an example.

### Running

See `newrelic_rabbitmq_plugin -h`

Use a process manager such as `upstart` to keep the process running.

## Support

Please use Github issues for support.
