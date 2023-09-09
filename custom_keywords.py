from robot.api import logger
from urllib.parse import urlparse, parse_qs

def get_query_string_parameter(url, param_name):
    parsed_url = urlparse(url)
    query_parameters = parse_qs(parsed_url.query)
    
    if param_name in query_parameters:
        return query_parameters[param_name][0]
    else:
        logger.warn(f"Parameter '{param_name}' not found in the URL: {url}")
        return None
