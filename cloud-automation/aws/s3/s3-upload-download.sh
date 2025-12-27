#!/usr/bin/env bash
set -euo pipefail

# S3 object operations:
# - Upload file
# - Download file

usage() {
  echo "Usage:"
  echo "  $0 upload <local_file> <bucket_name> <object_key>"
  echo "  $0 download <bucket_name> <object_key> <local_file>"
  exit 1
}

if [[ $# -lt 4 ]]; then
  usage
fi

ACTION="$1"

case "${ACTION}" in
  upload)
    LOCAL_FILE="$2"
    BUCKET="$3"
    KEY="$4"
    aws s3 cp "${LOCAL_FILE}" "s3://${BUCKET}/${KEY}"
    echo "Uploaded: ${LOCAL_FILE} -> s3://${BUCKET}/${KEY}"
    ;;
  download)
    BUCKET="$2"
    KEY="$3"
    LOCAL_FILE="$4"
    aws s3 cp "s3://${BUCKET}/${KEY}" "${LOCAL_FILE}"
    echo "Downloaded: s3://${BUCKET}/${KEY} -> ${LOCAL_FILE}"
    ;;
  *)
    usage
    ;;
esac
