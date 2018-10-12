# eks-demo
To create EKS cluster, configure AWS credential with env variaables and run in each stack:

```
  terraform init
  terraform plan --var-file=dev.tfvars
  terraform apply --var-file=dev.tfvars
```
