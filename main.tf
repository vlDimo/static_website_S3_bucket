# Creation of a S3 bucket in AWS
resource "aws_s3_bucket" "static_website_bucket" {  # We create a AWS S3 Bucket
  bucket = "vldimotesting1231.eu.org" # This is the name of the S3 Bucket ~ my configured domain over EU.org
}
# Static Website Hosting Configuration
resource "aws_s3_bucket_website_configuration" "website" { # This enables static website hosting ~ This tells aws how to serve files for people when they visit the website
  bucket = aws_s3_bucket.static_website_bucket.id  # this connects the website configuration to the existing s3 bucket

  index_document { # This is the default file which visitors see when they access the root url e.g. https://my-terraform-static-site12345/ but in browser we need http://my-terraform-static-site12345.s3-website-eu-central-1.amazonaws.com
    suffix = "index.html"
  }
  error_document { # If the directory is unknown like https://my-terraform-static-site12345/blabla then the error page will be loaded.
    key = "error.html"
  }
}
# S3 Bucket Policy Configuration
resource "aws_s3_bucket_policy" "cloudfront_access_policy" {
  bucket = aws_s3_bucket.static_website_bucket.id # Connect the S3 Policy to the S3 bucket
  # Now the policy follows: 
  policy = jsonencode({ # This converts the json format into Terraform format
    Version = "2012-10-17", 
    Statement = [
      {
        Effect = "Allow", # This allows the specified action
        Principal = {
            Service = "cloudfront.amazonaws.com"
        },  # This means just cloudfront can access data 
        Action = "s3:GetObject", # Allows just retrieving data (downloading) data from the bucket
        Resource = "${aws_s3_bucket.static_website_bucket.arn}/*", # Grants access to all objects in the bucket
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.website_distribution.arn # Just the CloudFront Distribution has access to this site
          }
        }
      }
    ]
  })
}
# CloudFront Configuration
resource "aws_cloudfront_origin_access_control" "oac" { # Creates an OAC for Cloudfront (Origin Access Control) ---> Indirect Access for users to the s3 bucket over OAC its like a Intermediary 
  name = "s3-origin-access" # Defines the name of the OAC
  origin_access_control_origin_type = "s3" # Specifies that the origin is an S3 Bucket
  signing_behavior = "always" # Ensures that all requests to the S3 bucket are signed
  signing_protocol = "sigv4" # Uses AWS Signature Version 4 (sigv4) for secure authentication
}

resource "aws_cloudfront_distribution" "website_distribution" { # CloudFront speeds up the content delivery by caching files (like backup) in different locations worldwide.  
    depends_on = [ aws_s3_bucket.static_website_bucket, aws_acm_certificate.ssl_cert ]
    origin { # This defines the origin where the CloudFront gets files from 
        domain_name = aws_s3_bucket.static_website_bucket.bucket_regional_domain_name # Specifies the S3 buckets regional domain name
        origin_access_control_id = aws_cloudfront_origin_access_control.oac.id # Attaches the previously created OAC to restrict direct S3 access
        origin_id = "S3Origin"  # A unique identifier for the origin
    }  
    enabled = true # Enables the CloudFront Distribution
    default_root_object = "index.html" # Sets index.html as the default page 
    aliases = [ "vldimotesting1231.eu.org" ]

    viewer_certificate { # SSL/TLS Security (HTTPS Configuration)
      acm_certificate_arn = aws_acm_certificate.ssl_cert.arn # Uses an AWS Certificate Manager (ACM) SSL certificate
      ssl_support_method = "sni-only" # Uses SNI-based SSL (cheaper options for HTTPS)
      minimum_protocol_version = "TLSv1.2_2021" # Ensures secure connections using TLS 1.2 or higher
    }
    restrictions { 
      geo_restriction { # Here you can insert any geographical restriction 
        restriction_type = "none" # Here you can add values like "blacklist" or "whitelist"
      }
    }
    default_cache_behavior { # Defines how CloudFront caches and serves files
      allowed_methods = ["GET", "HEAD"] # Only GET and HEAD requests are allowed
      cached_methods = ["GET", "HEAD"] # Specifies which methods should be cached
      target_origin_id = "S3Origin" # Links to the S3 bucket origin 
      viewer_protocol_policy = "redirect-to-https" # Automatically redirects users from http to https
      forwarded_values { # This tells CloudFront how to handle query string and cookies while forwarding
        query_string = false # This tells CloudFront not to forward query string for better cache efficiency ---> https://example.com/page.html?user=123 = https://example.com/page.html not with the string 
        cookies { # This tells CloudFront how to handle cookies to origin (S3 Bucket)
          forward = "none" # This tells CloudFront not to forward any cookies to the origin (S3 Bucket)
        }
      }
    }
    
}
# SSL Certificate for HTTPS (ACM) Configuration
resource "aws_acm_certificate" "ssl_cert" { # This creates an SSL certificate using AWS Certificate Manager (ACM)
  domain_name = "vldimotesting1231.eu.org" # This is the domain name the SSL Certificate is used for 
  validation_method = "DNS" # ACM requires validation to confirm you own the domain ---> AWS provides a special DNS record that you need to add to your domain

  lifecycle {
    create_before_destroy = true # That means that Terraform creates the new certificate first before deleting the old one
  }
}

# Upload Website Files to S3 
resource "aws_s3_object" "index_html" { # This tells Terraform to Upload a file to the S3 Bucket
  bucket = aws_s3_bucket.static_website_bucket.id # The object uploads the file to the s3 bucket created earlier
  key = "index.html" # This sets the filename in S3 
  source = "./index.html" # Specifies the filename from my local machine
  content_type = "text/html" # Defines the file type so that browsers understand its an HTML file 
}
resource "aws_s3_object" "error_html" { # -"- 
  bucket = aws_s3_bucket.static_website_bucket.id 
  key = "error.html"
  source = "./error.html"
  content_type = "text/html"
  }

  resource "aws_route53_zone" "my_domain_routing" {
    name = "vldimotesting1231.eu.org"
  }

  resource "aws_route53_record" "cloudfront_alias" {
    depends_on = [ aws_route53_zone.my_domain_routing ]
    zone_id = aws_route53_zone.my_domain_routing.zone_id
        name = "vldimotesting1231.eu.org"
    type = "A"
    alias {
      name = aws_cloudfront_distribution.website_distribution.domain_name
      zone_id = aws_cloudfront_distribution.website_distribution.hosted_zone_id
      evaluate_target_health = false
    }
  }