from datetime import datetime

def convert_date_to_24_hour_format(date_str, input_format, output_format):
    try:
        date_obj = datetime.strptime(date_str, input_format)
        return date_obj.strftime(output_format)
    except ValueError:
        return None
