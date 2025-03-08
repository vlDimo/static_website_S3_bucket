# AWS Static Website with Terraform

This Terraform project sets up a **fully automated static website** on AWS with:
- ✅ S3 for website hosting
- ✅ CloudFront for global content delivery
- ✅ Route 53 for custom domain management
- ✅ ACM for SSL certificate (HTTPS)

## Deployment Steps 

```sh 
git clone https://github.com/vlDimo/static_website_S3_bucket.git
cd static_website_S3_bucket 
terraform init
terraform plan
terraform apply -auto-approve

## ❌ Troubleshooting

### ❗ My domain is not resolving
**Possible Cause:** Your domain is not yet approved by EU.org.  
**Solution:** Run this command to check:
```sh
nslookup -type=NS yourdomain.eu.org 8.8.8.8
## If you see NXDOMAIN, wait 24-48 hours for approval

# ❗ My website is not using HTTPS
Possible Cause: The SSL certificate is not deployed.
Solution: Ensure the certificate is created in us-east-1 and is validated in ACM.

# ❗ Terraform says "AccessDenied"
Possible Cause: Your IAM user doesn’t have permissions.
Solution: Attach this policy in IAM:

json
Kopieren
Bearbeiten
{
    "Effect": "Allow",
    "Action": "route53:*",
    "Resource": "*"
}