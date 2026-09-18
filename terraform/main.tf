locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# --- S3 Bucket ---

resource "aws_s3_bucket" "website_bucket" {
  bucket = "${var.project_name}-${var.environment}-website-bucket"
  tags   = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "website_bucket_public_access" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "website_bucket_encryption" {
  bucket = aws_s3_bucket.website_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# --- CloudFront OAC ---

resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "${var.project_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# --- CloudFront Response Headers ---

resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name    = "${var.project_name}-security-headers"
  comment = "Security headers for portfolio site"

  security_headers_config {
    content_security_policy {
      override = true
      content_security_policy = "default-src 'self'; img-src 'self'; style-src 'self' 'unsafe-inline';"
    }
    frame_options {
      override = true
      frame_option = "DENY"
    }
    strict_transport_security {
      override = true
      sts_policy = "max-age=63072000; includeSubDomains; preload"
      preload = true
    }
    x_content_type_options {
      override = true
    }
    x_xss_protection {
      override = true
      protection = "1; mode=block"
    }
  }
}

# --- CloudFront Distribution ---

resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled             = true
  is_ipv6_enabled    = true
  price_class        = "PriceClass_200"
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.website_bucket.id}"
    origin_access_control_id  = aws_cloudfront_origin_access_control.s3_oac.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.website_bucket.id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress              = true
  }

  # Custom error response for Single Page Apps (SPA) or simple fallback
  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path   = "/index.html"
    error_caching_min_ttl = 1000
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = local.common_tags
}

# --- S3 Bucket Policy for CloudFront OAC ---

resource "aws_s3_bucket_policy" "allow_cloudfront_oac" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = data.aws_iam_policy_document.allow_cloudfront_oac_policy.json
}

data "aws_iam_policy_document" "allow_cloudfront_oac_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website_bucket.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}
