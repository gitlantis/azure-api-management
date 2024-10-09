init project
```bash
terraform init -backend-config="dev.backend.tfvars"
```

plan IaC
```bash
terraform plan -var "publisher_email=$PUBLISHER_EMAIL" -var "publisher_name=$PUBLISHER_NAME"
```

apply IaC
```bash
terraform apply -var "publisher_email=$PUBLISHER_EMAIL" -var "publisher_name=$PUBLISHER_NAME"
```
