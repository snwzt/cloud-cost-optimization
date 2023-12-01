import boto3
from datetime import datetime

'''
1. Volume doesn't exist -> delete
2. Volume is there, but not associated with any ec2 instance -> delete

invoke this at 2 am everyday with cloudwatch
'''

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')

    # fetch EBS snapshots
    ebs_snapshots = ec2.describe_snapshots(OwnerIds=['self'])

    # get all active EC2 instance id
    ec2_instances = ec2.describe_instances(Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
    active_instance_ids = set()

    for reservation in ec2_instances['Reservations']:
        for instance in reservation['Instances']:
            active_instance_ids.add(instance['InstanceId'])

    for snapshot in ebs_snapshots['Snapshots']:
        snapshot_id = snapshot['SnapshotId']
        volume_id = snapshot['VolumeId']

        if not volume_id:
            # delete snapshot if not attached to any volume
            ec2.delete_snapshot(SnapshotId=snapshot_id)
            print(f"EBS snapshot {snapshot_id} deleted, reason: not attached to any volumes.")

        else:
            try:
                volume_response = ec2.describe_volumes(VolumeIds=[volume_id])

                # look for volumes not attached to any running instance
                if not volume_response['Volumes'][0]['Attachments']:
                    ec2.delete_snapshot(SnapshotId=snapshot_id)
                    print(f"EBS snapshot {snapshot_id} deleted, reason: taken from a volume not attached to any running instance.")

            except ec2.exceptions.ClientError as e:
                if e.response['Error']['Code'] == 'InvalidVolume.NotFound':
                    # the volume associated with the snapshot is not found, it might have been deleted
                    ec2.delete_snapshot(SnapshotId=snapshot_id)
                    print(f"EBS snapshot {snapshot_id} deleted, reason: associated volume was not found.")
