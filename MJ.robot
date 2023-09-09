*** Settings ***
Library     RPA.Browser.Selenium    auto_close=${False}
Library     RPA.Robocorp.Vault
Library     RPA.Desktop
Library     String
Library     custom_keywords.py    WITH NAME    CustomKeywords
Library     BuiltIn
Library     Collections
Library     String_processing.py
Library     RPA.Windows
Library     Time.py
Library     RPA.Salesforce
Library     DateTime
Library     RPA.Excel.Files
Library     OperatingSystem
Library     RPA.Tables
Library     my_pandas_script.py
Library     RPA.Email.ImapSmtp
Library     RPA.Outlook.Application
Library     RPA.FileSystem


*** Variables ***
${URL_LOGIN}        https://fusebox-portal-vn-dev.azurewebsites.net/User/Login
${URL_EXLOG}        https://fusebox-portal-vn-dev.azurewebsites.net/Exlog
${OUTPUT_DIR}       D:/RPA/output
${BODY}             "______________REPORT______________"


*** Test Cases ***
Login
    Open Available Browser    ${URL_LOGIN}
    ${Datalogin}=    Get Secret    swaglabs
    Input Text    //input[@id="UserName"]    ${Datalogin}[username]
    Input Password    //input[@id="Password"]    ${Datalogin}[password]
    Click Button    //input[@type="submit"]

Exlog
    Go To    ${URL_EXLOG}
    Click Element    //body//p[1]/a[@href="/Exlog?page=1&size=15"]

LOG_ERORR
    ${page_number}=    Set Variable    1
    # GET CHUỖI LƯU GIÁ TRỊ SỐ TRANG
    ${page}=    RPA.Browser.Selenium.Get Text    //body/p[1]
    # Sử dụng biểu thức chính quy log ra chuỗi trong ()
    ${Sring_a}=    String_processing.Extract Number From String    ${page}
    # # Sử dụng biểu thức chính quy để tìm số trong chuỗi
    ${String_Max_page}=    String_processing.Extract Number From String1    ${Sring_a}
    ${String_b}=    Set Variable    ${String_Max_page}
    # Chuyển thành số nguyên loại bỏ dấu , khoảng trống gán cho giá trị là trang cuối cùng
    ${Max_page}=    Evaluate    int(${String_b.replace(",", "")})
    ${start_time}=    Set Variable    8:39 AM
    ${end_time}=    Set Variable    9:22 AM
    # Chuyển đổi thời gian sang định dạng 24 giờ
    ${start_time_24}=    Convert To 24 Hour Format    ${start_time}
    ${end_time_24}=    Convert To 24 Hour Format    ${end_time}

    ${column_table}=    Create List    Host    Code    Type    Error    Detail    User    Date    Time
    # Tạo table
    ${table_data}=    Create Table    columns=${column_table}    # Tạo bảng
    # Lấy ngày hôm nay(hiện tại)
    ${current_date}=    Get Current Date    
    ${logged_current_date}=    Get Variable Value    ${current_date}

    FOR    ${i}    IN RANGE    1    ${Max_page}
        # Đếm thẻ Tr trong table
        ${Quantity_TR}=    Execute Javascript
        ...    return document.querySelectorAll('table#ErrorLog tr.even-row, table#ErrorLog tr.odd-row').length

        FOR    ${j}    IN RANGE    2    ${Quantity_TR} + 2
            ${host}=    RPA.Browser.Selenium.Get Text    //table[@id="ErrorLog"]/tbody/tr[${j}]/td[1]
            ${code}=    RPA.Browser.Selenium.Get Text    //table[@id="ErrorLog"]/tbody/tr[${j}]/td[2]
            ${type}=    RPA.Browser.Selenium.Get Text    //table[@id="ErrorLog"]/tbody/tr[${j}]/td[3]
            ${error}=    RPA.Browser.Selenium.Get Text    //table[@id="ErrorLog"]/tbody/tr[${j}]/td[4]/span
            ${element_a}=    Set Variable    //table[@id="ErrorLog"]/tbody/tr[${j}]/td[4]/a
            ${Detail}=    Get Element Attribute    ${element_a}    href
            ${user}=    RPA.Browser.Selenium.Get Text    //table[@id="ErrorLog"]/tbody/tr[${j}]/td[5]
            ${date}=    RPA.Browser.Selenium.Get Text    //table[@id="ErrorLog"]/tbody/tr[${j}]/td[6]
            ${time}=    RPA.Browser.Selenium.Get Text    //table[@id="ErrorLog"]/tbody/tr[${j}]/td[7]

            # Chuyển đổi thời gian sang định dạng 24 giờ
            ${time}=    Convert To 24 Hour Format    ${time}
            ${time}=    Get Variable Value    ${time}
            ${start_time_24}=    Get Variable Value    ${start_time_24}
            ${end_time_24}=    Get Variable Value    ${end_time_24}
            # Chuyển ngày về định dạng %d/%m/%Y
            ${date_string}=    Set Variable    ${date}
            ${date_table}=    Convert Date String To Formatted Date    ${date_string}
            # Thực hiện lấy ra ngày hôm qua
            ${yesterday_datetime} =    Subtract Time From Date    ${current_date}    1 days
            ${yesterday_date} =    Convert Date    ${yesterday_datetime}    result_format=%d/%m/%Y
            ${logged_current_date_Yesterday}=    Get Variable Value    ${yesterday_date}    
            ${logged_date_table}=    Get Variable Value    ${date_table}
            
            IF    '${logged_date_table}' == '${logged_current_date_Yesterday}' and '${start_time_24}'<='${time}' and '${time}'<='${end_time_24}'
                Log To Console
                ...    \n Host: ${host}, Code: ${code}, Type: ${type}, Error: ${error},Detail:${Detail}, User: ${user}, Date: ${date}, Time: ${time}
                ${data_row}=    Create List    ${host}    ${code}    ${type}    ${error}    ${Detail}    ${user}    ${date}    ${time}
                Add Table Row    ${table_data}    ${data_row}
                # Đã log xong dữ liệu cho ngày hiện tại
            END
            
            IF    ${j} == ${Quantity_TR} + 1
                # Thực hiện các thao tác để chuyển trang 
                Click Element    //body//p[2]//a
            END
            
        END
        IF    '${logged_date_table}' == '${logged_current_date_Yesterday}' and '${start_time_24}'>'${time}'   Exit For Loop
    END
    Close Browser
    # ${page_number}=    Convert To Integer    ${page_number}
    # ${page_number}=    Evaluate    ${page_number} + 1
    # # Kiểm tra nếu đã đến trang cuối cùng thì dừng vòng lặp
    # IF    ${page_number} >= ${Max_page}    Exit For Loop

    ${DataFrame}=    Analyze Data    ${table_data}

    Log to console
    ...    ${DataFrame}
    # Xuat ra file excel
    EXPORT_Excel    ${table_data}    OUTPUT.xlsx    DATA    ${OUTPUT_DIR}
    # Kiểm tra điều kiện
    ${Datalogin}=    Get Secret    Email
    SEND_MAIL
    ...    ${Datalogin}[username]
    ...    ${Datalogin}[Tomail]
    ...    REBORT_'${logged_current_date}'
    ...    ${BODY}
    ...    D:/RPA/output/OUTPUT.xlsx


*** Keywords ***
Convert Date String To Formatted Date
    [Arguments]    ${date_string}
    # Tách ngày, tháng và năm từ chuỗi
    ${day}=    Get Substring    ${date_string}    0    1
    ${month}=    Get Substring    ${date_string}    2    3
    ${year}=    Get Substring    ${date_string}    4
    # Tạo đối tượng ngày từ ngày, tháng và năm
    ${date_object}=    Evaluate    datetime.datetime(int(${year}), int(${month}), int(${day}))
    # Định dạng lại thành chuỗi "EX:09/05/2023"
    ${formatted_date}=    Convert To String    ${date_object}
    ${date_table}=    Convert Date    ${formatted_date}    result_format=%m/%d/%Y
    RETURN    ${date_table}

EXPORT_Excel
    [Arguments]    ${table_data}    ${file_excel}    ${sheet_name}    ${OUTPUT_DIR}
    ${file_excel}=    Set Variable    ${OUTPUT_DIR}${/}${file_excel}
    # Tạo một tệp Excel mớiD:\RPA\output
    Create Workbook    path=${file_excel}
    Save Workbook
    # Mở workbook đã tạo
    Open Workbook    path=${file_excel}
    # Tạo một worksheet trong workbook
    Create Worksheet    name=${sheet_name}    content=${table_data}    header=True

    # Lưu tệp Excel
    Save Workbook    ${file_excel}

    # Đóng tệp Excel
    Close Workbook

SEND_MAIL
    [Arguments]    ${sender}    ${recipients}    ${subject}    ${body}    ${path_report}
    ${Datalogin}=    Get Secret    Email
    Authorize    account=${Datalogin}[username]    password=${Datalogin}[password]    smtp_server=smtp.gmail.com    smtp_port=587
    Send Message    sender=${sender}    recipients=${recipients}    subject= ${subject}    body=${body}    attachments=${path_report}
