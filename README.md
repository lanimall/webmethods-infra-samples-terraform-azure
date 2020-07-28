# webmethods-infra-automation-terraform

Author: Fabien Sanglier (fabien.sanglier@softwareaggov.com)

This is a DEMO project to automate and build webmethods environments in the cloud.
I will try to support both AWS and Azure via terraform providers (and maybe other) whenever possible...

This project only creates the cloud infrastructure (networks, VMs, security, load balancers, etc...), and DOES NOT install the software on the VMs etc... which will be the purpose of another "sister" project called "webmethods-infra-automation".

Again, this is a DEMO and by no mean a guide to actual production provisioning (although I try to follow best practices everywhere i can)

# Actual product provisioning 

Once the cloud infrastructure is setup, for the products provisioning, please refer to the sister ansible/command central project at:
See https://github.com/lanimall/webmethods-infra-samples for more details.