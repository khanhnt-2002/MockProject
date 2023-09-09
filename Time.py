def convert_to_24_hour_format(time_str):
    from datetime import datetime
    try:
        # Chuyển đổi thời gian sang định dạng 24 giờ
        time_obj = datetime.strptime(time_str, '%I:%M %p')
        return time_obj.strftime('%H:%M')
    except ValueError:
        # Xử lý lỗi nếu định dạng không hợp lệ
        return None
