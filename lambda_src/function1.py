import json

def lambda_handler(event, context):
    """
    AWS Lambda handler function
    """
    return {
        'statusCode': 200,
        'body': json.dumps('Hello World!')
    }
