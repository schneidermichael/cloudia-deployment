## Development deployment with kind

### Getting started
1. Start Docker Desktop
2. Create a cluster with `kind create cluster`
3. `kubectl config view --minify --flatten --context=kind-kind`
   1. Coppy the variables in the `terraform.tfvars`
      1. `host` corresponds with `clusters.cluster.server`.
      2. `client_certificate` corresponds with `users.user.client-certificate`.
      3. `client_key corresponds` with `users.user.client-key`.
      4. `cluster_ca_certificate` corresponds with `clusters.cluster.certificate-authority-data`.
4. Initialize your Terraform workspace with `terraform init` - once only
5. Apply the configuration with `terraform apply`
6. Confirm your apply with *yes*
7. Verify with `kubectl get all` the deployments/services are running
8. Expose your frontend with `kubectl port-forward service/cloudia-frontend 4200:4200`
9.  Go to http://localhost:4200/


### Clean up your workspace

1. Running `terraform destroy` will de-provision the deployments and services you have created
2. Confirm your destroy with a *yes*
3. Delete a cluster with `kind delete cluster`

### Reference Documentation

* [Docker](https://www.docker.com/get-started/)
* [Kubernetes](https://kubernetes.io/)
* [Terraform](https://www.terraform.io/)
* [kind](https://kind.sigs.k8s.io/)
