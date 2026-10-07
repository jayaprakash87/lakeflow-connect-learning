# Learning architecture

The first comparison uses the **same Google Drive folder** on both paths.

```mermaid
flowchart LR
    G[Google Drive folder<br/>eFuse JSON files]

    G --> M[Managed Google Drive connector]
    M --> BM[bronze.efuse_events_managed]

    G --> S[Standard Google Drive connector<br/>read_files / Auto Loader]
    S --> P[Lakeflow Pipeline]
    P --> BS[bronze.efuse_events_standard]

    BM --> C[Compare responsibility boundary]
    BS --> C

    C --> I[Incremental state / restart]
    C --> E[Schema evolution]
    C --> O[Monitoring / operations]
```

The source data stays constant. The main variable is the ingestion abstraction.

Kafka is retained later as an advanced streaming-specific experiment.
