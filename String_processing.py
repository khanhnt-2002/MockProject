import re
from bs4 import BeautifulSoup
import pandas as pd
def extract_number_from_string(input_string):
    # Sử dụng biểu thức chính quy để tìm số trong chuỗi
    ket_qua = re.search(r'\((.*?)\)', input_string)

    if ket_qua:
        so_trich_xuat = ket_qua.group()
        return so_trich_xuat
    else:
        return None
def extract_number_from_string1(input_string):
    # Sử dụng biểu thức chính quy để tìm số trong chuỗi
    ket_qua = re.search(r'(\d{1,3}(?:,\d{3})+)', input_string)

    if ket_qua:
        so_trich_xuat = ket_qua.group()
        return so_trich_xuat
    else:
        return None
def extract_href_from_a_tag(html):
        # Sử dụng BeautifulSoup để phân tích mã HTML
        soup = BeautifulSoup(html, 'html.parser')
        # Trích xuất giá trị của thuộc tính 'href' từ thẻ <a>
        href_value = soup.a['href']

        return href_value
def convert_robot_table_to_dataframe(robot_table):
    columns = robot_table[0]
    data = [row for row in robot_table[1:]]
    return pd.DataFrame(data, columns=columns)