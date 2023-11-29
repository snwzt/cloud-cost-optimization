# Cloud Cost Optimization by Identifying Stale Resources

## Identifying Stale EBS Snapshots:
In this Lambda function, stale EBS snapshots that are not associated with a volume or the assciated volumes are not associated with active ec2 instance are identified and deleted to reduce cloud costs. 

## Flowchart:
```mermaid
flowchart LR
    A(Cloudwatch) --> |cron <br> trigger| B(Lambda function)
    B --> C{attached to <br> a volume}
    C -->|yes| E{attached to <br> a running instance}
    C -->|no| H[delete snapshot]
    C -->|volume <br> not found| D[delete snapshot]
    E -->|yes| F[keep snapshot]
    E -->|no| G[delete snapshot]
```