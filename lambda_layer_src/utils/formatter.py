import json
from datetime import datetime
from decimal import Decimal
from typing import Any, Dict, List, Union

def format_response_data(data: Any) -> Any:
    """Format data for JSON serialization"""
    if isinstance(data, dict):
        return {key: format_response_data(value) for key, value in data.items()}
    elif isinstance(data, list):
        return [format_response_data(item) for item in data]
    elif isinstance(data, Decimal):
        return float(data)
    elif isinstance(data, datetime):
        return data.isoformat()
    else:
        return data

def mask_sensitive_data(data: Dict[str, Any], sensitive_fields: List[str] = None) -> Dict[str, Any]:
    """Mask sensitive data in response"""
    if sensitive_fields is None:
        sensitive_fields = ['password', 'token', 'secret', 'key']
    
    masked_data = data.copy()
    for field in sensitive_fields:
        if field in masked_data:
            masked_data[field] = '***MASKED***'
    
    return masked_data

def create_paginated_response(items: List[Any], page: int, page_size: int, total: int) -> Dict[str, Any]:
    """Create a standardized paginated response"""
    return {
        'items': format_response_data(items),
        'pagination': {
            'page': page,
            'page_size': page_size,
            'total': total,
            'has_more': (page * page_size) < total
        }
    }
