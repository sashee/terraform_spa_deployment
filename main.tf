provider "aws" {
}

terraform {
  required_version = ">= 0.12.8"
}

# frontend

resource "aws_s3_bucket" "frontend_bucket" {
  force_destroy = "true"
  website {
    index_document = "index.html"
  }
}

data "external" "frontend_build" {
  program = ["bash", "-c", <<EOT
(npm ci && npm run build -- --env.PARAM="$(jq -r '.param')") >&2 && echo "{\"dest\": \"dist\"}"
EOT
  ]
  working_dir = "${path.module}/frontend"
  query = {
    param = "Hi from Terraform!"
  }
}

locals {
  mime_type_mappings = {
    html = "text/html",
    js   = "application/javascript",
    css  = "text/css"
  }
}

resource "aws_s3_bucket_object" "frontend_object" {
  for_each = fileset("${data.external.frontend_build.working_dir}/${data.external.frontend_build.result.dest}", "*")

  key          = each.value
  source       = "${data.external.frontend_build.working_dir}/${data.external.frontend_build.result.dest}/${each.value}"
  bucket       = aws_s3_bucket.frontend_bucket.bucket
  etag         = filemd5("${data.external.frontend_build.working_dir}/${data.external.frontend_build.result.dest}/${each.value}")
  content_type = lookup(local.mime_type_mappings, concat(regexall("\\.([^\\.]*)$", each.value), [[""]])[0][0], "application/octet-stream")
}

# Boilerplate for the bucket

resource "aws_s3_bucket_policy" "default" {
  bucket = aws_s3_bucket.frontend_bucket.id
  policy = data.aws_iam_policy_document.default.json
}

data "aws_iam_policy_document" "default" {
  statement {
    actions = ["s3:GetObject"]

    resources = ["${aws_s3_bucket.frontend_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

output "frontend_url" {
  value = "${aws_s3_bucket.frontend_bucket.website_endpoint}"
}

