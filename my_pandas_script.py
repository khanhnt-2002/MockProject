import pandas as pd

# Hàm để thực hiện phân tích dữ liệu
def analyze_data(table):
    # Chuyển đổi biến ${table} thành DataFrame
    df = pd.DataFrame(table)

    duplicated_rows_count = df.duplicated().sum()

    grouped_data1 = df.groupby(['User']).agg({'Code': 'count', 'Type': 'count', 'Error': 'count'}).reset_index()
    
    # Nhóm dữ liệu theo các cột 'User', 'Type', và 'Error' và đếm số lượng dòng trong mỗi nhóm
    grouped_data2 = df.groupby(['User', 'Type', 'Error']).size().reset_index(name='Count')
    return df,  duplicated_rows_count, grouped_data1, grouped_data2

