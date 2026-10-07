# Why Google Drive is the first executable source

The initial plan used Kafka because the managed-vs-Structured-Streaming contrast is strong.

That introduced an avoidable dependency: a publicly reachable Kafka service. A hosted Kafka account can require billing details, while a broker on a laptop is not directly reachable from Databricks serverless compute.

Google Drive is a cleaner first experiment because Databricks provides both:

1. a **managed Google Drive connector**; and
2. a **standard Google Drive connector** using Spark/SQL APIs.

The same source folder and Unity Catalog connection can therefore be used for both paths.

This preserves the learning objective:

> Same source, same data, same destination semantics; change only the level of ingestion management.

Kafka remains valuable later because it exposes streaming offsets and continuous consumption more explicitly.
