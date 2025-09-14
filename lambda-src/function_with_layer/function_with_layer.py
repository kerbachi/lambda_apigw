import json
import logging

# Import utilities from the layer
try:
    from utils.logger import setup_logger, create_response, log_event_info
    from utils.validator import validate_email, validate_required_fields
    from utils.formatter import format_response_data
    LAYER_AVAILABLE = True
except ImportError:
    # Fallback if layer is not available
    LAYER_AVAILABLE = False
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)

def lambda_handler(event, context):
    """
    AWS Lambda handler function that demonstrates using utility layers
    """
    if LAYER_AVAILABLE:
        logger = setup_logger(__name__)
        log_event_info(logger, event, context)
        
        # Validate input
        body = event.get('body', '{}')
        if isinstance(body, str):
            try:
                body = json.loads(body)
            except json.JSONDecodeError:
                return create_response(400, {'error': 'Invalid JSON in request body'})
        
        required_fields = ['email', 'name']
        missing_fields = validate_required_fields(body, required_fields)
        if missing_fields:
            return create_response(400, {
                'error': f'Missing required fields: {", ".join(missing_fields)}'
            })
        
        # Validate email
        if not validate_email(body['email']):
            return create_response(400, {'error': 'Invalid email format'})
        
        # Process the data
        response_data = {
            'message': f'Hello {body["name"]}!',
            'email': body['email'],
            'processed_at': context.aws_request_id,
            'data': format_response_data(body)
        }
        
        logger.info("Successfully processed request")
        return create_response(200, response_data)
    
    else:
        # Fallback implementation without layer
        logger = logging.getLogger(__name__)
        logger.info(f"Function called with event: {json.dumps(event)}")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Hello World!',
                'layer_available': False
            })
        }
