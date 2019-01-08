output "bucket-name" {
  value = "${aws_s3_bucket.publish-bucket.*.id[0]}"
}
