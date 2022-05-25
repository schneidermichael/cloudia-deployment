## Create a GKE cluster with 3 nodes

### Getting started
1. Initialize your Terraform workspace with `terraform init` - once only
2. Apply the configuration with `terraform apply`
3. Confirm your apply with *yes*
4. You need to configure `kubectl` with `gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region $(terraform output -raw zone)`
5. Verify with `kubectl get all` the deployments/services are running


### Clean up your workspace

1. Running `terraform destroy` will de-provision the deployments and services you have created
2. Confirm your destroy with a *yes*
3. Check the status with `gcloud container clusters list`