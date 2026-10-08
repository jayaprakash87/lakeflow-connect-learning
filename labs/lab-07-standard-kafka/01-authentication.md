# Lab 07 — Authentication options

Authentication is one of the clearest differences between Lab 06 and Lab 07.

## Lab 06 managed

```text
UC Kafka Connection
    ↓
contains bootstrap servers + source authentication
    ↓
managed connector references connection by name
```

## Lab 07 standard

The standard Kafka source is configured directly through Spark/SQL source options.

### Preferred: Unity Catalog service credential

For supported cloud-managed Kafka services:

```python
.option(
    "databricks.serviceCredential",
    "<service-credential-name>"
)
```

This is available in Databricks Runtime 16.1+.

When using a service credential, do not also configure SASL mechanism, JAAS config, or security protocol options intended for password-based auth.

### Generic Kafka: SASL/SSL

Use Kafka options such as:

```text
kafka.security.protocol
kafka.sasl.mechanism
kafka.sasl.jaas.config
```

Never hardcode username/password.

Store them in a Databricks secret scope and retrieve them at runtime.

## Key learning

The managed Kafka **Connection** object is specific to the managed connector abstraction.

The standard Structured Streaming source instead uses normal Kafka Spark options and, where supported, a Unity Catalog **service credential**.
