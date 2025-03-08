# 🌐 AWS Static Website Deployment with Terraform

This Terraform project **automates the deployment of a static website** on AWS using:

- ✅ **Amazon S3** for static website hosting
- ✅ **Amazon CloudFront** for global content delivery (CDN)
- ✅ **Amazon Route 53** for custom domain management
- ✅ **AWS Certificate Manager (ACM)** for HTTPS/SSL security

---

## 📌 **Project Overview**
This infrastructure-as-code (IaC) setup allows you to deploy a **cost-effective, highly scalable, and secure** static website using AWS services. The website is globally distributed via **CloudFront** with **SSL/TLS encryption** and a **custom domain** managed through Route 53.

---

## 🚀 **Deployment Guide**
### **🔹 Prerequisites**
Before deploying, ensure you have:
- [Terraform](https://developer.hashicorp.com/terraform/downloads) installed.
- An [AWS account](https://aws.amazon.com/free/) with programmatic access configured.
- A **domain** registered via [EU.org](https://nic.eu.org/) or another provider.
- Proper IAM permissions to manage **S3, CloudFront, Route 53, and ACM**.

### **🔹 Steps to Deploy**
Run the following commands in your terminal:

```sh
# Clone the repository
git clone https://github.com/vlDimo/static_website_S3_bucket.git
cd static_website_S3_bucket

# Initialize Terraform
terraform init

# Preview changes before applying
terraform plan

# Deploy infrastructure automatically
terraform apply -auto-approve
