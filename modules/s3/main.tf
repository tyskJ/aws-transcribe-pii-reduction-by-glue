/************************************************************
Bucket - Transcribe Src
************************************************************/
### Bucket
resource "aws_s3_bucket" "transcribe_src" {
  bucket              = "transcribe-src-${var.account_id}-${var.region}-an"
  bucket_namespace    = "account-regional"
  force_destroy       = true
  object_lock_enabled = false
  tags = {
    Name = "transcribe-src-${var.account_id}-${var.region}-an"
  }
}

### Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "transcribe_src" {
  bucket                  = aws_s3_bucket.transcribe_src.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

### Object Ownership
resource "aws_s3_bucket_ownership_controls" "transcribe_src" {
  bucket = aws_s3_bucket.transcribe_src.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

### Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "transcribe_src" {
  bucket = aws_s3_bucket.transcribe_src.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled       = true
    blocked_encryption_types = ["SSE-C"]
  }
}

### Event Notifications
resource "aws_s3_bucket_notification" "transcribe_src_bucket_notification" {
  bucket      = aws_s3_bucket.transcribe_src.id
  eventbridge = true
}

/************************************************************
Bucket - Transcribe Dst
************************************************************/
resource "aws_s3_bucket" "transcribe_dst" {
  bucket              = "transcribe-dst-${var.account_id}-${var.region}-an"
  bucket_namespace    = "account-regional"
  force_destroy       = true
  object_lock_enabled = false
  tags = {
    Name = "transcribe-dst-${var.account_id}-${var.region}-an"
  }
}

### Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "transcribe_dst" {
  bucket                  = aws_s3_bucket.transcribe_dst.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

### Object Ownership
resource "aws_s3_bucket_ownership_controls" "transcribe_dst" {
  bucket = aws_s3_bucket.transcribe_dst.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

### Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "transcribe_dst" {
  bucket = aws_s3_bucket.transcribe_dst.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled       = true
    blocked_encryption_types = ["SSE-C"]
  }
}

/************************************************************
Bucket - Glue Src
************************************************************/
### Bucket
resource "aws_s3_bucket" "glue_src" {
  bucket              = "glue-src-${var.account_id}-${var.region}-an"
  bucket_namespace    = "account-regional"
  force_destroy       = true
  object_lock_enabled = false
  tags = {
    Name = "glue-src-${var.account_id}-${var.region}-an"
  }
}

### Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "glue_src" {
  bucket                  = aws_s3_bucket.glue_src.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

### Object Ownership
resource "aws_s3_bucket_ownership_controls" "glue_src" {
  bucket = aws_s3_bucket.glue_src.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

### Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "glue_src" {
  bucket = aws_s3_bucket.glue_src.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled       = true
    blocked_encryption_types = ["SSE-C"]
  }
}

/************************************************************
Bucket - Glue Dst
************************************************************/
### Bucket
resource "aws_s3_bucket" "glue_dst" {
  bucket              = "glue-dst-${var.account_id}-${var.region}-an"
  bucket_namespace    = "account-regional"
  force_destroy       = true
  object_lock_enabled = false
  tags = {
    Name = "glue-src-${var.account_id}-${var.region}-an"
  }
}

### Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "glue_dst" {
  bucket                  = aws_s3_bucket.glue_dst.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

### Object Ownership
resource "aws_s3_bucket_ownership_controls" "glue_dst" {
  bucket = aws_s3_bucket.glue_dst.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

### Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "glue_dst" {
  bucket = aws_s3_bucket.glue_dst.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled       = true
    blocked_encryption_types = ["SSE-C"]
  }
}

/************************************************************
Bucket - OutPuts
************************************************************/
### Bucket
resource "aws_s3_bucket" "output" {
  bucket              = "output-${var.account_id}-${var.region}-an"
  bucket_namespace    = "account-regional"
  force_destroy       = true
  object_lock_enabled = false
  tags = {
    Name = "output-${var.account_id}-${var.region}-an"
  }
}

### Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "output" {
  bucket                  = aws_s3_bucket.output.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

### Object Ownership
resource "aws_s3_bucket_ownership_controls" "output" {
  bucket = aws_s3_bucket.output.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

### Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "output" {
  bucket = aws_s3_bucket.output.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled       = true
    blocked_encryption_types = ["SSE-C"]
  }
}