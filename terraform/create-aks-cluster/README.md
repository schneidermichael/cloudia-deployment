## Create a AKS cluster with 3 nodes

### Getting started
1. Log in into Azure with `az login`
2. Create an Active Directory service principal account `az ad sp create-for-rbac --skip-assignment`
3. Update your `terraform.tfvars` file with your `appId` and `password`
4. Initialize your Terraform workspace with `terraform init` - once only
5. Apply the configuration with `terraform apply`
6. Confirm your apply with *yes*
7. You need to configure `kubectl` with `az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name)`
8. Verify with `kubectl get all` the deployments/services are running


### Clean up your workspace

1. Running `terraform destroy` will de-provision the deployments and services you have created
2. Confirm your destroy with a *yes*
3. Check the status with `gcloud container clusters list`