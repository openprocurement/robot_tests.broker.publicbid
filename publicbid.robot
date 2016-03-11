*** Settings ***
Library  Selenium2Screenshots
Library  String
Library  DateTime
Library  publicbid_service.py

*** Variables ***
${mail}          test_test@test.com
${telephone}     +380630000000

*** Keywords ***
Підготувати клієнт для користувача
  [Arguments]  @{ARGUMENTS}
  [Documentation]  Відкрити браузер, створити об’єкт api wrapper, тощо
  ...      ${ARGUMENTS[0]} ==  username
  Open Browser   ${USERS.users['${ARGUMENTS[0]}'].homepage}   ${USERS.users['${ARGUMENTS[0]}'].browser}   alias=${ARGUMENTS[0]}
  Set Window Size   @{USERS.users['${ARGUMENTS[0]}'].size}
  Set Window Position   @{USERS.users['${ARGUMENTS[0]}'].position}
  Run Keyword If   '${ARGUMENTS[0]}' != 'Publicbid_Viewer'   Вхід  ${ARGUMENTS[0]}

Вхід
  [Arguments]  ${username}
  Run Keyword And Ignore Error   Wait Until Page Contains Element    xpath=//*[text()='Реєстрація/Вхід']   10
  Click Element                      xpath=//*[text()='Реєстрація/Вхід']
  Run Keyword And Ignore Error   Wait Until Page Contains Element   id=mForm:email   10
  Input text   id=mForm:email      ${USERS.users['${username}'].login}
  Sleep  2
  Input text   id=mForm:pwd      ${USERS.users['${username}'].password}
  Click Button   id=mForm:login
  Sleep  3


Створити тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data
  Log  ${ARGUMENTS[1]}
  ${file_path}=        local_path_to_file   TestDocument.docx
  ${prepared_tender_data}=  Get From Dictionary  ${ARGUMENTS[1]}  data
  ${items}=         Get From Dictionary   ${prepared_tender_data}               items
  ${title}=         Get From Dictionary   ${prepared_tender_data}               title
  ${description}=   Get From Dictionary   ${prepared_tender_data}               description
  ${budget}=        Get From Dictionary   ${prepared_tender_data.value}         amount
  ${step_rate}=     Get From Dictionary   ${prepared_tender_data.minimalStep}   amount
  ${enquiry_period}=  Get From Dictionary  ${prepared_tender_data}  enquiryPeriod
  ${enquiry_period_end_date}=  publicbid_service.convert_date_to_string  ${enquiry_period.endDate}
  ${tender_period}=  Get From Dictionary  ${prepared_tender_data}  tenderPeriod
  ${tender_period_start_date}=  publicbid_service.convert_date_to_string  ${tender_period.startDate}
  ${tender_period_end_date}=  publicbid_service.convert_date_to_string  ${tender_period.endDate}
  ${countryName}=   Get From Dictionary   ${prepared_tender_data.procuringEntity.address}       countryName
  ${item_description}=  Get From Dictionary  ${items[0]}  description
  ${delivery_end_date}=      Get From Dictionary   ${items[0].deliveryDate}   endDate
  ${delivery_end_date}=      publicbid_service.convert_item_date_to_string  ${delivery_end_date}
  ${item_delivery_address_street_address}=  Get From Dictionary  ${items[0].deliveryAddress}  streetAddress
  ${cpv}=           Convert To String     "Картонки"
  ${cpv_id}=           Get From Dictionary   ${items[0].classification}         id
  ${cpv_id_1}=           Get Substring    ${cpv_id}   0   3
  ${dkpp_desc}=     Get From Dictionary   ${items[0].additionalClassifications[0]}   description
  ${dkpp_id}=       Get From Dictionary   ${items[0].additionalClassifications[0]}  id
  ${code}=           Get From Dictionary   ${items[0].unit}          code
  ${quantity}=      Get From Dictionary   ${items[0]}                        quantity
  ${name}=      Get From Dictionary   ${prepared_tender_data.procuringEntity.contactPoint}       name

  Selenium2Library.Switch Browser     ${ARGUMENTS[0]}
  Wait Until Page Contains Element    xpath=//*[text()='Нова закупівля']   10
  Click Element                       xpath=//*[text()='Нова закупівля']
  Wait Until Page Contains Element    id=mForm:data:name
  Input text                          id=mForm:data:name     ${title}
  Input text                          id=mForm:data:desc     ${description}
  Input text                          id=mForm:data:budget   ${budget}
  Input text                          id=mForm:data:step     ${step_rate}
  Input text                          xpath=//*[@id="mForm:data:dEA_input"]  ${enquiry_period_end_date}
  Input text                          xpath=//*[@id="mForm:data:dSPr_input"]  ${tender_period_start_date}
  Input text                          xpath=//*[@id="mForm:data:dEPr_input"]  ${tender_period_end_date}
  Click Element                       xpath=//*[@id='mForm:data:vat']/tbody/tr/td[1]//span
  Click Element                       id=mForm:data:cKind_label
  Click Element                       xpath=//div[@id='mForm:data:cKind_panel']//li[3]
  Input text                          id=mForm:data:cCpvGr_input      ${cpv_id_1}
  Wait Until Page Contains Element    xpath=.//*[@id='mForm:data:cCpvGr_panel']/table/tbody/tr/td[2]/span   10
  Click Element                       xpath=.//*[@id='mForm:data:cCpvGr_panel']/table/tbody/tr/td[2]/span
  Input text                          id=mForm:data:subject0    ${item_description}
  Input text                          id=mForm:data:cCpv0_input   ${cpv_id}
  Wait Until Page Contains Element    xpath=//div[@id='mForm:data:cCpv0_panel']//td[1]/span   10
  Click Element                       xpath=//div[@id='mForm:data:cCpv0_panel']//td[1]/span
  Input text                          id=mForm:data:unit0_input    ${code}
  Wait Until Page Contains Element    xpath=//div[@id='mForm:data:unit0_panel']//tr/td[1]   10
  Click Element                       xpath=//div[@id='mForm:data:unit0_panel']//tr/td[1]
  Input text                          id=mForm:data:amount0   ${quantity}
  Input text                          id=mForm:data:cDkpp0_input    ${dkpp_id}
  Wait Until Page Contains Element    xpath=//div[@id='mForm:data:cDkpp0_panel']//tr[1]/td[2]/span   10
  Click Element                       xpath=//div[@id='mForm:data:cDkpp0_panel']//tr[1]/td[2]/span
  Input text                          xpath=//*[@id="mForm:data:delDE0_input"]  ${delivery_end_date}
  Input text                          xpath=//*[@id="mForm:data:delAdr0"]  ${item_delivery_address_street_address}
  Input text                          id=mForm:data:rName    ${name}
  Input text                          id=mForm:data:rPhone    ${telephone}
  Input text                          id=mForm:data:rMail   ${mail}
  Завантажити документ до тендеру  ${file_path}
  Sleep  2
  Run Keyword if   '${mode}' == 'multi'   Додати предмет   items
  # Save
  Click Element                       xpath=//*[@id="mForm:bSave"]
  Sleep   20
  # Announce
  Click Element                       xpath=//span[text()="Оголосити"]
  Sleep   2
  # Confirm in message box
  Click Element                       xpath=//div[contains(@class, "ui-confirm-dialog") and @aria-hidden="false"]//span[text()="Оголосити"]
  Sleep   15
  Click Element                       xpath=//span[contains(@class, "ui-button-text ui-c") and text()="Так"]
  # More smart wait for id is needed there.
  Sleep   2

  ${bid_status}=  Get Text  xpath=//*[@id="mForm:data:status"]
  :FOR    ${INDEX}    IN RANGE    1    25
  \  Exit For Loop If  '${bid_status}' == 'Період уточнень'
  \  Sleep  3
  \  ${bid_status}=  Get Text  xpath=//*[@id="mForm:data:status"]
  \  Run Keyword If  '${bid_status}' != 'Період уточнень'  Sleep  15
  \  Run Keyword If  '${bid_status}' != 'Період уточнень'  Reload Page

  ${tender_UAid}=  Get Text           id=mForm:nBid
  ${tender_UAid}=  Get Substring  ${tender_UAid}  19
  ${Ids}       Convert To String  ${tender_UAid}
  Run keyword if   '${mode}' == 'multi'   Set Multi Ids   ${tender_UAid}
  [return]  ${Ids}

Завантажити документ до тендеру
  [Arguments]   ${file}
  Log  ${file}
  Choose File       id=mForm:data:docFile_input     ${file}
  Sleep  2
  Selenium2Library.Capture Page Screenshot
  Wait Until Page Contains Element    xpath=//*[text()='Картка документу']  10
  Click Element  id=mForm:docCard:dcType_label
  Wait Until Page Contains Element  id=mForm:docCard:dcType_panel  10
  Click Element  xpath=//*[@id="mForm:docCard:dcType_panel"]/div/ul/li[2]
  Click Element  xpath=//*[@id="mForm:docCard:docCard"]/table/tfoot/tr/td/button[1]
  Sleep  2

Завантажити документ
  [Arguments]   ${username}  ${file}  ${tender_uaid}
  Log  ${username}
  Log  ${file}
  Log  ${tender_uaid}
  publicbid.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Завантажити документ до тендеру  ${file}
  Input text  id=mForm:data:docAdjust     Test text
  Click Element  xpath=//*[@id="mForm:bSave"]


Set Multi Ids
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${tender_UAid}
  ${id}=           Get Text           id=mForm:nBid
  ${Ids}   Create List    ${tender_UAid}   ${id}

Додати предмет
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  items
  ${dkpp_desc1}=     Get From Dictionary   ${items[1].additionalClassifications[0]}   description
  ${dkpp_id11}=      Get From Dictionary   ${items[1].additionalClassifications[0]}  id
  ${dkpp_desc2}=     Get From Dictionary   ${items[2].additionalClassifications[0]}   description
  ${dkpp_id2}=       Get From Dictionary   ${items[2].additionalClassifications[0]}  id
  ${dkpp_desc3}=     Get From Dictionary   ${items[3].additionalClassifications[0]}   description
  ${dkpp_id3}=       Get From Dictionary   ${items[3].additionalClassifications[0]}  id

  Wait Until Page Contains Element   xpath=//button[@class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"]   10
  Wait Until Page Contains Element   xpath=//button[contains(@class, 'ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only')]   10
  Wait Until Page Contains Element   xpath=//span[text()="Додати предмет"]   10
  Click Element                      xpath=//span[text()="Додати предмет"]
  Wait Until Page Contains Element   id=mForm:data:subject1   10
  Input text                         id=mForm:data:subject1    ${dkpp_desc1}
  Input text                         id=mForm:data:cCpv1_input   ${cpv_id}
  Wait Until Page Contains Element   xpath=//div[@id='mForm:data:cCpv1_panel']/table/tbody/tr/td[1]/span   10
  Click Element                      xpath=//div[@id='mForm:data:cCpv1_panel']/table/tbody/tr/td[1]/span
  Input text                         id=mForm:data:unit1_input    ${code}
  Wait Until Page Contains Element   xpath=//div[@id='mForm:data:unit1_panel']/table/tbody/tr/td[1]   10
  Click Element                      xpath=//div[@id='mForm:data:unit1_panel']/table/tbody/tr/td[1]
  Input text                         id=mForm:data:amount1   ${quantity}
  Input text                         id=mForm:data:cDkpp1_input    ${dkpp_id11}
  Wait Until Page Contains Element   xpath=//div[@id='mForm:data:cDkpp1_panel']/table/tbody/tr/td[1]/span   10
  Click Element                      xpath=//div[@id='mForm:data:cDkpp1_panel']/table/tbody/tr/td[1]/span
  Click Element                      xpath=//span[text()="Додати предмет"]
  Wait Until Page Contains Element   id=mForm:data:subject2   10
  Input text                         id=mForm:data:subject2    ${dkpp_desc2}
  Input text                         id=mForm:data:cCpv2_input   ${cpv_id}
  Wait Until Page Contains Element   xpath=//div[@id='mForm:data:cCpv2_panel']/table/tbody/tr/td[1]/span   10
  Click Element                      xpath=//div[@id='mForm:data:cCpv2_panel']/table/tbody/tr/td[1]/span
  Input text                         id=mForm:data:unit2_input    ${code}
  Wait Until Page Contains Element   xpath=//div[@id='mForm:data:unit2_panel']/table/tbody/tr/td[1]   10
  Click Element                      xpath=//div[@id='mForm:data:unit2_panel']/table/tbody/tr/td[1]
  Input text                         id=mForm:data:amount2   ${quantity}
  Input text                         id=mForm:data:cDkpp2_input    ${dkpp_id2}
  Wait Until Page Contains Element   xpath=//div[@id='mForm:data:cDkpp2_panel']/table/tbody/tr/td[1]/span   10
  Click Element                      xpath=//div[@id='mForm:data:cDkpp2_panel']/table/tbody/tr/td[1]/span
  Click Element                      xpath=//span[text()="Додати предмет"]
  Wait Until Page Contains Element   id=mForm:data:subject3   10
  Input text                         id=mForm:data:subject3    ${dkpp_desc3}
  Input text                         id=mForm:data:cCpv3_input   ${cpv_id}
  Wait Until Page Contains Element   xpath=//div[@id='mForm:data:cCpv3_panel']/table/tbody/tr/td[1]/span   10
  Click Element                      xpath=//div[@id='mForm:data:cCpv3_panel']/table/tbody/tr/td[1]/span
  Input text                         id=mForm:data:unit3_input    ${code}
  Wait Until Page Contains Element   xpath=//div[@id='mForm:data:unit3_panel']/table/tbody/tr/td[1]   10
  Click Element                      xpath=//div[@id='mForm:data:unit3_panel']/table/tbody/tr/td[1]
  Input text                         id=mForm:data:amount3   ${quantity}
  Input text                         id=mForm:data:cDkpp3_input    ${dkpp_id3}
  Wait Until Page Contains Element   xpath=//div[@id='mForm:data:cDkpp3_panel']/table/tbody/tr/td[1]/span   10
  Click Element                      xpath=//div[@id='mForm:data:cDkpp3_panel']/table/tbody/tr/td[1]/span

Пошук тендера по ідентифікатору
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tenderId
  ...      ${ARGUMENTS[2]} ==  id
  Switch browser   ${ARGUMENTS[0]}
  ${current_location}=   Get Location
  Wait Until Page Contains   Офіційний майданчик державних закупівель України   10
  sleep  1
  Click Element  xpath=//a[./text()="Закупівлі"]
  sleep  5
  Input Text   xpath=//*[@id="mForm:datalist:nBidClmn"]/div/input  ${ARGUMENTS[1]}
  Press Key  xpath=//*[@id="mForm:datalist:nBidClmn"]/div/input  \\13
  Sleep  10
  :FOR    ${INDEX}    IN RANGE    1    30
  \  ${find}=  Run Keyword And Return Status  Page Should Contain Element  xpath=//*[text()='${ARGUMENTS[1]}']
  \  Exit For Loop If  '${find}' == 'True'
  \  Sleep  10
  \  Clear Element Text  xpath=//*[@id="mForm:datalist:nBidClmn"]/div/input
  \  Input Text   xpath=//*[@id="mForm:datalist:nBidClmn"]/div/input  ${ARGUMENTS[1]}
  \  Press Key  xpath=//*[@id="mForm:datalist:nBidClmn"]/div/input  \\13
  \  Sleep  5
  Click Element    xpath=//*[text()='${ARGUMENTS[1]}']
  Wait Until Page Contains    ${ARGUMENTS[1]}   10
  Sleep  3
  Capture Page Screenshot

Отримати інформацію із тендера
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  fieldname
  Switch browser   ${ARGUMENTS[0]}
  Capture Page Screenshot
  Run Keyword And Return  Отримати інформацію про ${ARGUMENTS[1]}

Отримати інформацію про title
  ${return_value}=   Get Text  xpath=//*[@id="mForm:data:name"]
  [return]  ${return_value}

Отримати інформацію про description
  ${return_value}=   Get Text  xpath=//*[@id="mForm:data:desc"]
  [return]  ${return_value}

Отримати інформацію про value.amount
  ${return_value}=   Get Value  xpath=//*[@id="mForm:data:budget"]
  Log  ${return_value}
  ${return_value}=   Convert To Number   ${return_value}
  [return]  ${return_value}

Отримати інформацію про tenderID
  ${return_value}=  Get Text           id=mForm:nBid
  ${return_value}=  Get Substring  ${return_value}  19
  ${return_value}=  Convert To String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про procuringEntity.name
  ${return_value}=  Get Text           xpath=//*[@id="mForm:data:orgName"]
  Fail  "Не реализован функционал"
  [return]  ${return_value}

Отримати інформацію про enquiryPeriod.startDate
  ${return_value}=  Get Text           xpath=//*[@id="mForm:data:da"]
  Fail  "Не реализован функционал"
  [return]  ${return_value}

Отримати інформацію про enquiryPeriod.endDate
  ${return_value}=  Get Value           xpath=//*[@id="mForm:data:dEA_input"]
  ${return_value}=  publicbid_service.parse_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про tenderPeriod.startDate
  ${return_value}=  Get Value           xpath=//*[@id="mForm:data:dSPr_input"]
  ${return_value}=  publicbid_service.parse_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про tenderPeriod.endDate
  ${return_value}=  Get Value           xpath=//*[@id="mForm:data:dEPr_input"]
  ${return_value}=  publicbid_service.parse_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про minimalStep.amount
  ${return_value}=  Get Value           xpath=//*[@id="mForm:data:step"]
  Fail  "Не реализован функционал"
  [return]  ${return_value}

Внести зміни в тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  publicbid.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Wait Until Page Contains Element   xpath=//*[@id="mForm:data:status"]   10
  ${tender_status}=  Get Text  xpath=//*[@id="mForm:data:status"]
  ${new_description}=  Convert To String  Новое описания тендера
  Run Keyword If  '${tender_status}' == 'Період уточнень'  Input text  xpath=//*[@id="mForm:data:desc"]  ${new_description}
  Click Element              xpath=//*[@id="mForm:bSave"]
  Sleep  10
  Capture Page Screenshot

Отримати інформацію про items[0].description
  ${return_value}=  Get Text           xpath=//*[@id="mForm:data:subject0"]
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryDate.endDate
  ${return_value}=  Get Value           xpath=//*[@id="mForm:data:delDE0_input"]
  ${return_value}=  publicbid_service.parse_item_date  ${return_value}
#  Fail  "На майданчику не вказуються години і хвилини"
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryLocation.latitude
  ${return_value}=  Get Value           xpath=//*[@id="mForm:data:delLoc0"]
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryLocation.longitude
  ${return_value}=  Get Value           xpath=//*[@id="mForm:data:delLoc0"]
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.countryName
  ${return_value}=  Get Value           xpath=//*[@id="mForm:data:delLoc0"]
  Fail  "Не реализован функционал"
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.postalCode
  ${return_value}=  Get Value           xpath=//*[@id="mForm:data:delLoc0"]
  Fail  "Не реализован функционал"
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.region
  ${return_value}=  Get Value           xpath=//*[@id="mForm:data:delLoc0"]
  Fail  "Не реализован функционал"
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.locality
  ${return_value}=  Get Value           xpath=//*[@id="mForm:data:delAdr0"]
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.streetAddress
  ${return_value}=  Get Value           xpath=//*[@id="mForm:data:delAdr0"]
  [return]  ${return_value}

Отримати інформацію про items[0].classification.scheme
  ${return_value}=  Get Text           xpath=//*[@id="mForm:data:bidItem0"]/tbody/tr[3]/td/label
  ${return_value}=  Get Substring  ${return_value}  36  39
  ${return_value}=  Convert To String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].classification.id
  ${return_value}=  Get Value           xpath=//*[@id="mForm:data:cCpv0_input"]
  [return]  ${return_value}

Отримати інформацію про items[0].classification.description
  ${return_value}=  Get Text           xpath=//*[@id="mForm:data:nCpv0"]
  [return]  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].scheme
  ${return_value}=  Get Text           xpath=//*[@id="mForm:data:bidItem0"]/tbody/tr[3]/td[3]/label
  ${return_value}=  Get Substring  ${return_value}  36  40
  ${return_value}=  Convert To String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].id
  ${return_value}=  Get Value           xpath=//*[@id="mForm:data:cDkpp0_input"]
  [return]  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].description
  ${return_value}=  Get Text           xpath=//*[@id="mForm:data:nDkpp0"]
  [return]  ${return_value}

Отримати інформацію про items[0].unit.name
  ${return_value}=  Get Value           xpath=//*[@id="mForm:data:unit0_input"]
  ${return_value}=  Get Substring  ${return_value}  4
  ${return_value}=  Convert To String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].unit.code
  ${return_value}=  Get Value           xpath=//*[@id="mForm:data:unit0_input"]
  ${return_value}=  Get Substring  ${return_value}  0  3
  ${return_value}=  Convert To String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].quantity
  ${return_value}=  Get Value           xpath=//*[@id="mForm:data:amount0"]
  ${return_value}=  Convert To Number  ${return_value}
  [return]  ${return_value}


Задати питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} = question_data

  ${title}=        Get From Dictionary  ${ARGUMENTS[2].data}  title
  ${description}=  Get From Dictionary  ${ARGUMENTS[2].data}  description

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  publicbid.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Wait Until Page Contains Element   xpath=//*[@id="mForm:data:status"]   10
  ${tender_status}=  Get Text  xpath=//*[@id="mForm:data:status"]
  Run Keyword If  '${tender_status}' != 'Період уточнень'  Fail  "Період уточнень закінчився"
  Click Element  xpath=//span[./text()='Обговорення']
  Input Text  xpath=//*[@id="mForm:messT"]  ${title}
  Input Text  xpath=//*[@id="mForm:messQ"]  ${description}
#  Sleep  1200
  Sleep  5
#  Fail  "Проблемы со временем на сервере"
  Click Element  xpath=//*[@id="mForm:btnQ"]
  Sleep  30

Оновити сторінку з тендером
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  publicbid.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Reload Page

Отримати інформацію про questions[0].title
  Fail  "Анонімний користувач не може переглядати обговорення"
  ${return_value}=  Get Text  xpath=//*[@id="mForm:data_data"]/tr/td[1]/span
  [return]  ${return_value}

Отримати інформацію про questions[0].description
  Fail  "Анонімний користувач не може переглядати обговорення"
  ${return_value}=  Get Text  xpath=//*[@id="mForm:data_data"]/tr/td[1]
  [return]  ${return_value}

Отримати інформацію про questions[0].date
  Fail  "Анонімний користувач не може переглядати обговорення"
  ${return_value}=  Get Text  xpath=//*[@id="mForm:data_data"]/tr/td[2]
  [return]  ${return_value}

Отримати інформацію про questions[0].answer
  Fail  "Анонімний користувач не може переглядати обговорення"
  ${return_value}=  Get Text  xpath=//*[@id="mForm:data_data"]/tr[1]/td[1]/span
  [return]  ${return_value}

Подати цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  ${test_bid_data}
  Sleep  200
  ${amount}=        Get From Dictionary   ${ARGUMENTS[2].data.value}         amount
  publicbid.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  ${tender_status}=  Get Text  xpath=//*[@id="mForm:data:status"]
  Run Keyword If  '${tender_status}' == 'Період уточнень'  Fail  "Неможливо подати цінову пропозицію в період уточнень"
  Click Element  xpath=//*[text()='Зареєструвати пропозицію']
  Sleep  2
  Input Text  xpath=//*[@id="mForm:data:amount"]  ${amount}
  Input Text  xpath=//*[@id="mForm:data:rName"]  Тестовий закупівельник
  Input Text  xpath=//*[@id="mForm:data:rPhone"]  ${telephone}
  Input Text  xpath=//*[@id="mForm:data:rMail"]  ${mail}
  Click Element  xpath=//*[text()='Зберегти']
  Sleep  2
  Click Element  xpath=//*[text()='Зареєструвати пропозицію']
  ${status}=  Run Keyword And Return Status  Page Should Not Contain Element  xpath=//*[text()='Так']
  Run Keyword If  '${status}' == 'True'  Click Element  xpath=//*[text()='Так']
  Sleep  5
  ${status}=  Run Keyword And Return Status  Page Should Contain Element  xpath=//*[@id="mForm:opt1"]
  Run Keyword If  '${status}' == 'True'  Click Element  xpath=//*[@id="mForm:opt1"]/div[2]/span
  Run Keyword If  '${status}' == 'True'  Click Element  xpath=//*[text()='Подати пропозицію']
  Sleep  5
  ${bid_number}=  Get Text  xpath=//*[@id="mForm:data"]/div[1]/table/tbody/tr[1]/td[2]
  Sleep  80
  [return]  ${bid_number}

Скасувати цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  bid_number
  Log Many  @{ARGUMENTS}
  Пошук цінової пропозиції  ${ARGUMENTS[0]}  ${ARGUMENTS[2]}
  Click Element  xpath=//*[text()='Відмінити пропозицію']
  Click Element  xpath=//*[text()='Так']
  Sleep  3


Пошук цінової пропозиції
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  bid_number
  Log Many  @{ARGUMENTS}
  Switch browser   ${ARGUMENTS[0]}
  Click Element  xpath=//*[text()='Мій кабінет']
  Sleep  2
  Click Element  xpath=//*[text()='Мої пропозиції']
  Sleep  3
  Click Element  xpath=//*[@id="mForm:propsRee_data"]/tr[1]/td[1]/div





Відповісти на питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} = 0
  ...      ${ARGUMENTS[3]} = answer_data

  ${answer}=     Get From Dictionary  ${ARGUMENTS[3].data}  answer

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  publicbid.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Wait Until Page Contains Element   xpath=//*[@id="mForm:data:status"]   10
  ${tender_status}=  Get Text  xpath=//*[@id="mForm:data:status"]
  Run Keyword If  '${tender_status}' != 'Період уточнень'  Fail  "Період уточнень закінчився"
  Click Element                      xpath=//span[./text()='Обговорення']
  Sleep  3
  Click Element                      xpath=//*[@id="mForm:data_data"]/tr[1]/td[3]/button
  Input Text  xpath=//*[@id="mForm:messT"]  "Test answer"
  Input Text  xpath=//*[@id="mForm:messQ"]  ${answer}
  Click Element                      xpath=//*[@id="mForm:btnR"]
  Sleep  4

Отримати посилання на аукціон для глядача
  [Arguments]  ${username}  ${tender_uaid}
  [Documentation]
  ...   ${username} === username
  ...   ${tender_uaid} == tender_uaid

  Selenium2Library.Switch Browser    ${username}
  publicbid.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Page Should Contain Element  xpath=//*[text()='Перегляд аукціону']
  Click Element  xpath=//*[text()='Перегляд аукціону']
  Sleep  3
  ${url}=  Get Location
  Log  ${url}




