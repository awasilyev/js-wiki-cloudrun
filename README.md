# Installation

create terraform.auto.tfvar, set project, region, domain

get public ip address:

```
terraform init
terraform apply --target=google_compute_global_address.wiki
```

create A dns record for wiki domain using that address. required to get google managed certificate.

deploy all other resources:

```
terraform apply
```

# Deinstallation
terraform destroy

# Known issues
s3 configuration via env variables does not work,
it is needed to configure it manually via wiki web ui
