import os
import boto3
import logging
from botocore.exceptions import NoCredentialsError, PartialCredentialsError

# Set up logging
logging.basicConfig(
    format='%(asctime)s - %(levelname)s - %(message)s',
    level=logging.INFO,
)

def upload_to_s3(bucket_name, file_path, object_name=None):
    """
    Upload a file to an S3 bucket.

    :param bucket_name: Name of the S3 bucket https://taqatpay.s3.me-south-1.amazonaws.com/
    :param file_path: Path to the file to upload
    :param object_name: S3 object name. If None, file_path name is used.
    """
    # If S3 object name is not provided, use file name
    if object_name is None:
        object_name = os.path.basename(file_path)

    # Initialize S3 client
    s3_client = boto3.client('s3')

    try:
        # Upload the file
        logging.info(f"Uploading {file_path} to bucket {bucket_name} as {object_name}...")
        s3_client.upload_file(file_path, bucket_name, object_name)
        logging.info("Upload successful!")
    except FileNotFoundError:
        logging.error(f"File {file_path} not found.")
    except NoCredentialsError:
        logging.error("AWS credentials not found.")
    except PartialCredentialsError:
        logging.error("Incomplete AWS credentials provided.")
    except Exception as e:
        logging.error(f"An error occurred: {e}")

if __name__ == "__main__":
    import argparse

    # Argument parser for command-line use
    parser = argparse.ArgumentParser(description="Upload files to an S3 bucket.")
    parser.add_argument("bucket", help="Name of the S3 bucket")
    parser.add_argument("file", help="Path to the file to upload")
    parser.add_argument("--object", help="Optional: S3 object name (default: file name)")

    args = parser.parse_args()

    # Run the upload function
    upload_to_s3(args.bucket, args.file, args.object)