# management plane setup

Setting up the management plane

## Cloud provisoning

### Prep steps

Download management configs / secrets from S3 onto your workstation:

```bash
aws s3 sync s3://saggov-admin-resources/saggov_shared_management_azure/config/ ~/mydevsecrets/saggov_shared_management_azure/configs/
```

### Create workload environment

Run the following from your terraform client/workstation to provision the cloud environment

```bash
./cloud-apply.sh ${ENVCODE}
```

### Destroy workload environment

Run the following from your terraform client/workstation to provision the cloud environment

```bash
./cloud-destroy.sh ${ENVCODE}
```

## Prepare Management Environment

### Setup Access to bastion / management server

This will copy the SSH keys necessary to access the bastion and management server:

```bash
./scripts/setup-access-bastion.sh ${ENVCODE}
```