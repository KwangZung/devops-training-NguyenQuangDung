import boto3
import sys
from botocore.exceptions import ClientError

def generate_presigned_url(bucket_name, object_name, expiration=300):
    """Generate a presigned URL to share an S3 object"""
    s3_client = boto3.client('s3', region_name='us-east-1')
    try:
        response = s3_client.generate_presigned_url('get_object',
                                                    Params={'Bucket': bucket_name,
                                                            'Key': object_name},
                                                    ExpiresIn=expiration)
    except ClientError as e:
        print(e)
        return None

    return response

if __name__ == '__main__':
    BUCKET_NAME = 'private-dung-5555'
    OBJECT_NAME = 'private.pdf'
    
    url = generate_presigned_url(BUCKET_NAME, OBJECT_NAME)
    if url:
        print(f"Presigned URL:\n\n{url}")
