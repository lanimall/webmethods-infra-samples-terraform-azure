# common / cloud-base / buckets

This creates the bastions in the new env

## Create stack

```bash
env=prod
terraform get -update=true
terraform init -backend-config=configs/${env}-backend.conf
terraform plan -var-file=configs/${env}.tfvars -var-file=$HOME/mydevsecrets/saggov_shared_management_azure/configs/${env}/security/secrets.tfvars
terraform apply -var-file=configs/${env}.tfvars -var-file=$HOME/mydevsecrets/saggov_shared_management_azure/configs/${env}/security/secrets.tfvars
```

## Destroy stack

```bash
env=prod
terraform get -update=true
terraform init -backend-config=configs/${env}-backend.conf
terraform destroy -var-file=configs/${env}.tfvars -var-file=$HOME/mydevsecrets/saggov_shared_management_azure/configs/${env}/security/secrets.tfvars
```
