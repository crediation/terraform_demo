# Terraform Demo

The demo deployes a metabase container into a GKE cluster using terraform. Terraform also provision a posgtres database for metabase.

## Requirements
 
  - terraform
  - gcloud

## Setup

 - Edit the file example.vars and add fill out the variables needed by terraform. You can rename the file if you want to.
 - Run `terraform init -var-file=example.tfvars` to initialize terraform state
 - Run `terraform apply -var-file=example.tfvars` to provision your infrastrucutre.

## Troubleshooting

Should you keep getting an unauthorised error, run `gcloud auth application-default login` on your shell to authenticate the provider google without a credentials file
