import re
from typing import Any, Dict, List, Optional

def validate_email(email: str) -> bool:
    """Validate email format"""
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None

def validate_required_fields(data: Dict[str, Any], required_fields: List[str]) -> List[str]:
    """Validate that all required fields are present and not empty"""
    missing_fields = []
    for field in required_fields:
        if field not in data or data[field] is None or data[field] == '':
            missing_fields.append(field)
    return missing_fields

def validate_string_length(value: str, min_length: int = 0, max_length: Optional[int] = None) -> bool:
    """Validate string length constraints"""
    if len(value) < min_length:
        return False
    if max_length is not None and len(value) > max_length:
        return False
    return True

def sanitize_input(input_str: str) -> str:
    """Basic input sanitization to prevent injection attacks"""
    if not isinstance(input_str, str):
        return str(input_str)
    
    # Remove potentially dangerous characters
    sanitized = re.sub(r'[<>"\']', '', input_str)
    return sanitized.strip()
