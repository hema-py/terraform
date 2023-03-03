resource "aws_s3_bucket" "website_bucket" {
  bucket = var.domain_name
  acl = "public-read"
  policy = data.aws_iam_policy_document.website_policy.json
  provisioner "local-exec" {
        command = "aws s3 sync webpage/ s3://www.hema-domain.com"
  }
  website {
    index_document = "index.html"
  }
}
