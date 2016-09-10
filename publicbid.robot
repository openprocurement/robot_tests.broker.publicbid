*** Settings ***
Library  Selenium2Library
Library  String
Library  publicbid_json_util.py
Library  publicbid_service.py

*** Variables ***
${mail}          test_test@test.com
${telephone}     +380630000000
${bid_number}

*** Keywords ***
Підготувати дані для оголошення тендера
  [Arguments]  @{ARGUMENTS}
  ${adapted_data}=  adapt_data  ${ARGUMENTS[1]}
  Log Many  @{ARGUMENTS}
  [return]  ${adapted_data}


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
  Run Keyword And Ignore Error   Wait Until Page Contains Element    xpath=//*[text()='Вхід']   10
  Click Element                      xpath=//*[text()='Вхід']
  Run Keyword And Ignore Error   Wait Until Page Contains Element   id=mForm:email   10
  Input text   id=mForm:email      ${USERS.users['${username}'].login}
  Input text   id=mForm:pwd      ${USERS.users['${username}'].password}
  Click Button   id=mForm:login
  Sleep  3


Створити тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data
  ${file_path}=        local_path_to_file   TestDocument.docx
  ${prepared_tender_data}=  Get From Dictionary  ${ARGUMENTS[1]}  data
  ${items}=         Get From Dictionary   ${prepared_tender_data}               items
  ${title}=         Get From Dictionary   ${prepared_tender_data}               title
  ${description}=   Get From Dictionary   ${prepared_tender_data}               description
  ${budget}=        get_budget   ${prepared_tender_data}
  ${step_rate}=     get_step_rate  ${prepared_tender_data}
  ${enquiry_period}=  Get From Dictionary  ${prepared_tender_data}  enquiryPeriod
  ${enquiry_period_end_date}=  publicbid_service.convert_date_to_string  ${enquiry_period.endDate}
  ${tender_period}=  Get From Dictionary  ${prepared_tender_data}  tenderPeriod
  ${tender_period_start_date}=  publicbid_service.convert_date_to_string  ${tender_period.startDate}
  ${tender_period_end_date}=  publicbid_service.convert_date_to_string  ${tender_period.endDate}
  ${countryName}=   Get From Dictionary   ${prepared_tender_data.procuringEntity.address}       countryName
  ${item_description}=  Get From Dictionary  ${items[0]}  description
  ${item_locality}=  Get From Dictionary  ${items[0].deliveryAddress}  locality
  ${delivery_end_date}=      Get From Dictionary   ${items[0].deliveryDate}   endDate
  ${delivery_end_date}=      publicbid_service.convert_item_date_to_string  ${delivery_end_date}
  ${item_delivery_address_street_address}=  Get From Dictionary  ${items[0].deliveryAddress}  streetAddress
  ${item_delivery_postal_code}=  Get From Dictionary  ${items[0].deliveryAddress}  postalCode
  ${cpv}=           Convert To String     "Картонки"
  ${cpv_id}=           Get From Dictionary   ${items[0].classification}         id
  ${cpv_id_1}=           Get Substring    ${cpv_id}   0   3
  ${code}=           Get From Dictionary   ${items[0].unit}          code
  ${quantity}=      Get From Dictionary   ${items[0]}                        quantity
  ${name}=      Get From Dictionary   ${prepared_tender_data.procuringEntity.contactPoint}       name
  ${dkpp_id}=  Convert To String  1.13

  Selenium2Library.Switch Browser     ${ARGUMENTS[0]}
  Wait Until Page Contains Element    xpath=//*[text()='НОВА ЗАКУПІВЛЯ']   10
  Click Element                       xpath=//*[text()='НОВА ЗАКУПІВЛЯ']
  Sleep  3
  Wait Until Page Contains Element    id=mForm:name  10
  Input text                          id=mForm:name     ${title}
  Input text                          id=mForm:desc     ${description}
  Input text                          id=mForm:budget   ${budget}
  Sleep  5
  Input text                          id=mForm:step     ${step_rate}
  Input text                          xpath=//*[@id="mForm:dEA_input"]  ${enquiry_period_end_date}
  Input text                          xpath=//*[@id="mForm:dSPr_input"]  ${tender_period_start_date}
  Input text                          xpath=//*[@id="mForm:dEPr_input"]  ${tender_period_end_date}
  Click Element                       xpath=//*[@id="mForm:vat"]/tbody/tr/td[1]/div/div[2]/span
  Input text                          id=mForm:cCpvGr_input      ${cpv_id_1}
  Wait Until Page Contains Element    xpath=//*[@id="mForm:cCpvGr_panel"]/table/tbody/tr   10
  Click Element                       xpath=//*[@id="mForm:cCpvGr_panel"]/table/tbody/tr
  Input text                          id=mForm:bidItem_0:subject    ${item_description}
  Input text                          id=mForm:bidItem_0:cCpv_input   ${cpv_id}
  Wait Until Page Contains Element    xpath=//div[@id='mForm:bidItem_0:cCpv_panel']//td[1]/span   10
  Click Element                       xpath=//div[@id='mForm:bidItem_0:cCpv_panel']//td[1]/span
  Input text                          id=mForm:bidItem_0:unit_input    ${code}
  Wait Until Page Contains Element    xpath=//div[@id='mForm:bidItem_0:unit_panel']//tr/td[1]   10
  Click Element                       xpath=//div[@id='mForm:bidItem_0:unit_panel']//tr/td[1]
  Input text                          id=mForm:bidItem_0:amount   ${quantity}
  Input text                          xpath=//*[@id="mForm:bidItem_0:delDE_input"]  ${delivery_end_date}
  Click Element                       xpath=//*[@id="mForm:bidItem_0:cReg"]/div[3]
  Sleep  1
  Click Element                       xpath=//*[@id="mForm:bidItem_0:cReg_items"]/li[2]
  Sleep  1
  Input Text                       xpath=//*[@id="mForm:bidItem_0:cTer_input"]  ${item_locality}
  Sleep  2
  Click Element                       xpath=//*[@id="mForm:bidItem_0:cTer_panel"]/table/tbody/tr
  Sleep  1
  Input text                          id=mForm:bidItem_0:zc  ${item_delivery_postal_code}
  Input text                          xpath=//*[@id="mForm:bidItem_0:delAdr"]  ${item_delivery_address_street_address}
  Input text                          id=mForm:rName    ${name}
  Input text                          id=mForm:rPhone    ${telephone}
  Input text                          id=mForm:rMail   ${mail}
  Завантажити документ до тендеру  ${file_path}
  Sleep  2
  Run Keyword if   '${mode}' == 'multi'   Додати предмет   items
  # Save
  Execute JavaScript  window.scrollTo(0,0)
  Click Element                       xpath=//*[@id="mForm:bSave"]
  Sleep  5
  Click Element                       xpath=//*[@id="mForm:needAnnounce"]/div[3]/button/span
  Sleep   5
  # Announce
  Click Element                       xpath=//span[text()="Оголосити"]
  Sleep   2
  # Confirm in message box
  Click Element                       xpath=//div[contains(@class, "ui-confirm-dialog") and @aria-hidden="false"]//span[text()="Оголосити"]
  Sleep   5
  Click Element                       xpath=//span[contains(@class, "ui-button-text ui-c") and text()="Так"]
  # More smart wait for id is needed there.
  Sleep   2

  ${bid_status}=  Get Text  xpath=//*[@id="mForm:status"]
  :FOR    ${INDEX}    IN RANGE    1    25
  \  Exit For Loop If  '${bid_status}' == 'Період уточнень'
  \  Sleep  3
  \  ${bid_status}=  Get Text  xpath=//*[@id="mForm:status"]
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
  Choose File       id=mForm:docFile_input     ${file}
  Sleep  2
  Selenium2Library.Capture Page Screenshot
  Wait Until Page Contains Element    xpath=//*[text()='Картка документу']  10
  Click Element  id=mForm:docCard:dcType_label
  Wait Until Page Contains Element  id=mForm:docCard:dcType_panel  10
  Click Element  xpath=//*[@id="mForm:docCard:dcType_1"]
  Click Element  xpath=//*[@id="mForm:docCard:docCard"]/table/tfoot/tr/td/button[1]
  Sleep  2

Завантажити документ
  [Arguments]   ${username}  ${file}  ${tender_uaid}
  Log  ${username}
  Log  ${file}
  Log  ${tender_uaid}
  publicbid.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Execute JavaScript  window.scrollTo(0,500)
  Завантажити документ до тендеру  ${file}
  Input text  id=mForm:docAdjust     Test text
  Execute JavaScript  window.scrollTo(0,0)
  Click Element  xpath=//*[@id="mForm:bSave"]
  Sleep  3
  Click Element  xpath=//*[@id="primefacesmessagedlg"]/div/a


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
  Wait Until Page Contains Element   id=mForm:subject1   10
  Input text                         id=mForm:subject1    ${dkpp_desc1}
  Input text                         id=mForm:cCpv1_input   ${cpv_id}
  Wait Until Page Contains Element   xpath=//div[@id='mForm:cCpv1_panel']/table/tbody/tr/td[1]/span   10
  Click Element                      xpath=//div[@id='mForm:cCpv1_panel']/table/tbody/tr/td[1]/span
  Input text                         id=mForm:unit1_input    ${code}
  Wait Until Page Contains Element   xpath=//div[@id='mForm:unit1_panel']/table/tbody/tr/td[1]   10
  Click Element                      xpath=//div[@id='mForm:unit1_panel']/table/tbody/tr/td[1]
  Input text                         id=mForm:amount1   ${quantity}
  Input text                         id=mForm:cDkpp1_input    ${dkpp_id11}
  Wait Until Page Contains Element   xpath=//div[@id='mForm:cDkpp1_panel']/table/tbody/tr/td[1]/span   10
  Click Element                      xpath=//div[@id='mForm:cDkpp1_panel']/table/tbody/tr/td[1]/span
  Click Element                      xpath=//span[text()="Додати предмет"]
  Wait Until Page Contains Element   id=mForm:subject2   10
  Input text                         id=mForm:subject2    ${dkpp_desc2}
  Input text                         id=mForm:cCpv2_input   ${cpv_id}
  Wait Until Page Contains Element   xpath=//div[@id='mForm:cCpv2_panel']/table/tbody/tr/td[1]/span   10
  Click Element                      xpath=//div[@id='mForm:cCpv2_panel']/table/tbody/tr/td[1]/span
  Input text                         id=mForm:unit2_input    ${code}
  Wait Until Page Contains Element   xpath=//div[@id='mForm:unit2_panel']/table/tbody/tr/td[1]   10
  Click Element                      xpath=//div[@id='mForm:unit2_panel']/table/tbody/tr/td[1]
  Input text                         id=mForm:amount2   ${quantity}
  Input text                         id=mForm:cDkpp2_input    ${dkpp_id2}
  Wait Until Page Contains Element   xpath=//div[@id='mForm:cDkpp2_panel']/table/tbody/tr/td[1]/span   10
  Click Element                      xpath=//div[@id='mForm:cDkpp2_panel']/table/tbody/tr/td[1]/span
  Click Element                      xpath=//span[text()="Додати предмет"]
  Wait Until Page Contains Element   id=mForm:subject3   10
  Input text                         id=mForm:subject3    ${dkpp_desc3}
  Input text                         id=mForm:cCpv3_input   ${cpv_id}
  Wait Until Page Contains Element   xpath=//div[@id='mForm:cCpv3_panel']/table/tbody/tr/td[1]/span   10
  Click Element                      xpath=//div[@id='mForm:cCpv3_panel']/table/tbody/tr/td[1]/span
  Input text                         id=mForm:unit3_input    ${code}
  Wait Until Page Contains Element   xpath=//div[@id='mForm:unit3_panel']/table/tbody/tr/td[1]   10
  Click Element                      xpath=//div[@id='mForm:unit3_panel']/table/tbody/tr/td[1]
  Input text                         id=mForm:amount3   ${quantity}
  Input text                         id=mForm:cDkpp3_input    ${dkpp_id3}
  Wait Until Page Contains Element   xpath=//div[@id='mForm:cDkpp3_panel']/table/tbody/tr/td[1]/span   10
  Click Element                      xpath=//div[@id='mForm:cDkpp3_panel']/table/tbody/tr/td[1]/span

Пошук тендера по ідентифікатору
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tenderId
  ...      ${ARGUMENTS[2]} ==  id
  Switch browser   ${ARGUMENTS[0]}
  Click Element  xpath=//a[./text()="Закупівлі"]
  Sleep  2
  Click Element  xpath=//*[@id="buttons"]/button[1]
  Input Text   xpath=//*[@id="mForm:search-by-number-input"]  ${ARGUMENTS[1]}
  Press Key  xpath=//*[@id="mForm:search-by-number-input"]  \\13
  Sleep  1
  :FOR    ${INDEX}    IN RANGE    1    30
  \  ${find}=  Run Keyword And Return Status  Page Should Contain Element  xpath=//*[text()='${ARGUMENTS[1]}']
  \  Exit For Loop If  '${find}' == 'True'
  \  Sleep  10
  \  Clear Element Text  xpath=//*[@id="mForm:search-by-number-input"]
  \  Input Text   xpath=//*[@id="mForm:search-by-number-input"]  ${ARGUMENTS[1]}
  \  Press Key  xpath=//*[@id="mForm:search-by-number-input"]  \\13
  \  Sleep  5
  Click Element    xpath=//*[text()='${ARGUMENTS[1]}']
  Wait Until Page Contains    ${ARGUMENTS[1]}   10

Отримати інформацію із тендера
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  fieldname
  Switch browser   ${ARGUMENTS[0]}
  Log  ${TENDER['TENDER_UAID']}
  Run Keyword And Return  Отримати інформацію про ${ARGUMENTS[1]}

Отримати інформацію про value.currency
  ${return_value}=  Get Text  id=mForm:currency_label
  ${return_value}=  Convert To String  UAH
  [return]  ${return_value}

Отримати інформацію про value.valueAddedTaxIncluded
  ${return_value}=  Convert To Boolean  True
  [return]  ${return_value}

Отримати інформацію про title
  ${return_value}=   Get Text  xpath=//*[@id="mForm:name"]
  [return]  ${return_value}

Отримати інформацію про description
  ${return_value}=   Get Text  xpath=//*[@id="mForm:desc"]
  [return]  ${return_value}

Отримати інформацію про value.amount
  ${return_value}=   Get Value  xpath=//*[@id="mForm:budget"]
  Log  ${return_value}
  ${return_value}=   Convert To Number   ${return_value}
  [return]  ${return_value}

Отримати інформацію про auctionID
  ${return_value}=  Get Text           id=mForm:nBid
  ${return_value}=  Get Substring  ${return_value}  19
  ${return_value}=  Convert To String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про procuringEntity.name
  ${return_value}=  Get Text           xpath=//*[@id="mForm:orgName"]
  [return]  ${return_value}

Отримати інформацію про enquiryPeriod.startDate
  ${return_value}=  Get Text           xpath=//*[@id="mForm:da"]
  Fail  "Особливість реалізації, дата початку періоду уточнень = даті оголошення закупівлі"
  [return]  ${return_value}

Отримати інформацію про enquiryPeriod.endDate
  ${return_value}=  Get Value           xpath=//*[@id="mForm:dEA_input"]
  ${return_value}=  publicbid_service.parse_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про tenderPeriod.startDate
  ${return_value}=  Get Value           xpath=//*[@id="mForm:dSPr_input"]
  ${return_value}=  publicbid_service.parse_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про tenderPeriod.endDate
  ${return_value}=  Get Value           xpath=//*[@id="mForm:dEPr_input"]
  ${return_value}=  publicbid_service.parse_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про minimalStep.amount
  ${return_value}=  Get Value           xpath=//*[@id="mForm:step"]
  ${return_value}=  Convert To Number  ${return_value}
  [return]  ${return_value}

Внести зміни в тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  publicbid.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Wait Until Page Contains Element   xpath=//*[@id="mForm:status"]   10
  ${tender_status}=  Get Text  xpath=//*[@id="mForm:status"]
  ${new_description}=  Convert To String  Новое описания тендера
  Run Keyword If  '${tender_status}' == 'Період уточнень'  Input text  xpath=//*[@id="mForm:desc"]  ${new_description}
  Click Element              xpath=//*[@id="mForm:bSave"]
  Sleep  3

Отримати інформацію про items[0].description
  ${return_value}=  Get Text           xpath=//*[@id="mForm:bidItem_0:subject"]
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryDate.endDate
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:item0"]/tbody/tr[5]/td[4]/input
  ${return_value}=  publicbid_service.parse_item_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryLocation.latitude
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:delLoc1"]
  Run Keyword And Return  Convert To Number  ${return_value}

Отримати інформацію про items[0].deliveryLocation.longitude
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:delLoc2"]
  Run Keyword And Return  Convert To Number  ${return_value}

Отримати інформацію про items[0].deliveryAddress.countryName
  ${return_value}=  Get Text           xpath=//*[@id="mForm:bidItem_0:nState"]
  ${return_value}=  capitalize_first_letter  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.postalCode
  ${postal_code_1_exitsts}=  Run Keyword And Return Status  Page Should Contain Element  xpath=//*[@id="mForm:bidItem_0:zc"]
  ${postal_code}=  Run Keyword If  ${postal_code_1_exitsts}  Get Value  xpath=//*[@id="mForm:bidItem_0:zc"]
  ...         ELSE  Get Value  xpath=//*[@id="mForm:bidItem_0:zcText"]
  [return]  ${postal_code}

Отримати інформацію про items[0].deliveryAddress.region
  ${region_1_exitsts}=  Run Keyword And Return Status  Page Should Contain Element  xpath=//*[@id="mForm:bidItem_0:cReg_label"]
  ${region}=  Run Keyword If  ${region_1_exitsts}  Get Text  xpath=//*[@id="mForm:bidItem_0:cReg_label"]
  ...         ELSE  Get Value  xpath=//*[@id="mForm:bidItem_0:cRegText"]
  [return]  ${region}

Отримати інформацію про items[0].deliveryAddress.locality
  ${ter_1_exitsts}=  Run Keyword And Return Status  Page Should Contain Element  xpath=//*[@id="mForm:bidItem_0:cTer_input"]
  ${ter}=  Run Keyword If  ${ter_1_exitsts}  Get Value  xpath=//*[@id="mForm:bidItem_0:cTer_input"]
  ...         ELSE  Get Value  xpath=//*[@id="mForm:bidItem_0:cTerText"]
  [return]  ${ter}

Отримати інформацію про items[0].deliveryAddress.streetAddress
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:delAdr"]
  [return]  ${return_value}

Отримати інформацію про items[0].classification.scheme
  ${return_value}=  Get Text           xpath=//*[@id="mForm:bidItem_0:item0"]/tbody/tr[3]/td/label
  ${return_value}=  Get Substring  ${return_value}  36  39
  ${return_value}=  Convert To String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].classification.id
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:cCpv_input"]
  [return]  ${return_value}

Отримати інформацію про items[0].classification.description
  ${return_value}=  Get Text           xpath=//*[@id="mForm:bidItem_0:nCpv"]
  [return]  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].scheme
  ${return_value}=  Get Text           xpath=//*[@id="mForm:bidItem_0:item0"]/tbody/tr[3]/td[3]/label
  ${return_value}=  Get Substring  ${return_value}  36  40
  ${return_value}=  Convert To String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].id
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:cDkpp_input"]
  [return]  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].description
  ${return_value}=  Get Text           xpath=//*[@id="mForm:bidItem_0:nDkpp"]
  ${return_value}=  Strip String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].unit.name
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:unit_input"]
  ${return_value}=  Get Substring  ${return_value}  4
  ${return_value}=  Convert To String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].unit.code
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:unit_input"]
  ${return_value}=  Get Substring  ${return_value}  0  3
  ${return_value}=  Convert To String  ${return_value}
  [return]  ${return_value}

Отримати інформацію про items[0].quantity
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:amount"]
  ${return_value}=  Convert To Number  ${return_value}
  [return]  ${return_value}

Отримати інформацію про status
  Capture Page Screenshot
  Reload Page
  ${return_value}=  Get Text  xpath=//*[@id="mForm:status"]
  ${return_value}=  get_tender_code  ${return_value}
  ${return_value}=  Convert To String  ${return_value}
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
  Wait Until Page Contains Element   xpath=//*[@id="mForm:status"]   20
  ${tender_status}=  Get Text  xpath=//*[@id="mForm:status"]
  Run Keyword If  '${tender_status}' != 'Період уточнень'  Fail  "Період уточнень закінчився"
  Click Element  xpath=//span[./text()='Обговорення']
  Input Text  xpath=//*[@id="mForm:messT"]  ${title}
  Input Text  xpath=//*[@id="mForm:messQ"]  ${description}
  Click Element  xpath=//*[@id="mForm:btnQ"]
  Sleep  2

Оновити сторінку з тендером
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  publicbid.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}   ${ARGUMENTS[1]}

Отримати інформацію про questions[0].title
  Click Element  xpath=//*[text()="Обговорення"]
  Sleep  5
  ${return_value}=  Get Text  xpath=//*[@id="mForm:data_data"]/tr[1]/td[1]/span[1]
  [return]  ${return_value}

Отримати інформацію про questions[0].description
  ${return_value}=  Get Text  xpath=//*[@id="mForm:data_data"]/tr[1]/td[1]/span[2]
  [return]  ${return_value}

Отримати інформацію про questions[0].date
  ${return_value}=  Get Text  xpath=//*[@id="mForm:data_data"]/tr/td[4]
  ${return_value}=  publicbid_service.parse_date  ${return_value}
  [return]  ${return_value}

Отримати інформацію про questions[0].answer
  Click Element  xpath=//*[text()="Обговорення"]
  Sleep  5
  ${return_value}=  Get Text  xpath=//*[@id="mForm:data_data"]/tr[2]/td[1]/span[2]
  [return]  ${return_value}

Подати цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  ${test_bid_data}
  ${amount}=        Get From Dictionary   ${ARGUMENTS[2].data.value}         amount
  publicbid.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  ${tender_status}=  Get Text  xpath=//*[@id="mForm:status"]
  Run Keyword If  '${tender_status}' == 'Період уточнень'  Fail  "Неможливо подати цінову пропозицію в період уточнень"
  Click Element  xpath=//*[text()='Подати пропозицію']
  Sleep  2
  Input Text  xpath=//*[@id="mForm:data:amount"]  ${amount}
  Input Text  xpath=//*[@id="mForm:data:rName"]  Тестовий закупівельник
  Input Text  xpath=//*[@id="mForm:data:rPhone"]  ${telephone}
  Input Text  xpath=//*[@id="mForm:data:rMail"]  ${mail}
  Execute JavaScript  window.scrollTo(0,0)
  Click Element  xpath=//*[text()='Зберегти']
  Sleep  3
  Click Element  xpath=//*[@id="mForm:proposalSaveInfo"]/div[3]/button/span[2]
  Sleep  1
  Click Element  xpath=//*[text()='Зареєструвати пропозицію']
  Sleep  5
  Click Element  xpath=//div[@id="mForm:cdPay"]//span[text()='Зареєструвати пропозицію']
  Sleep  5
  ${bid_number}=  Get Text  xpath=//*[@id="mForm:data"]/div[1]/table/tbody/tr[3]/td[2]
  Selenium2Library.Capture Page Screenshot
  Sleep  45
  [return]  ${bid_number}

Скасувати цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  bid_number
  Log Many  @{ARGUMENTS}
  Пошук цінової пропозиції  ${ARGUMENTS[0]}  ${ARGUMENTS[2]}
  Selenium2Library.Capture Page Screenshot
  Click Element  xpath=//*[@id="mForm:proposalCancelBtn"]
  Selenium2Library.Capture Page Screenshot
  Click Element  xpath=//*[@id="mForm:proposalCancelBtnYes"]
  Sleep  5


Пошук цінової пропозиції
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  bid_number
  Log Many  @{ARGUMENTS}
  Switch browser   ${ARGUMENTS[0]}
  Click Element  xpath=//div[contains(@class, 'cabinet-user-name')]
  Sleep  3
  Click Element  xpath=//*[@id="wrapper"]/div/span
  Selenium2Library.Capture Page Screenshot
  Sleep  2
  Click Element  xpath=//*[text()='Мої пропозиції']
  Sleep  3
  Selenium2Library.Capture Page Screenshot
  Click Element  xpath=//*[@id="mForm:propsRee_data"]/tr[1]/td[1]/div
  Sleep  2
  Click Element  xpath=//*[@id="mForm:propsRee:0:browseProposalDetailBtn"]
  Sleep  4


Відповісти на питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} = 0
  ...      ${ARGUMENTS[3]} = answer_data

  ${answer}=     Get From Dictionary  ${ARGUMENTS[3].data}  answer

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  Sleep  5
  publicbid.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Wait Until Page Contains Element   xpath=//*[@id="mForm:status"]   10
  ${tender_status}=  Get Text  xpath=//*[@id="mForm:status"]
  Run Keyword If  '${tender_status}' != 'Період уточнень'  Fail  "Період уточнень закінчився"
  Click Element                      xpath=//span[./text()='Обговорення']
  Sleep  3
  Click Element                      xpath=//*[@id="mForm:data_data"]/tr[1]/td[5]/button
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
  Selenium2Library.Capture Page Screenshot
  Sleep  3
  ${url}=  Get Element Attribute  id=mForm:auctionLink@href
  [return]  ${url}

Отримати посилання на аукціон для учасника
  [Arguments]  ${username}  ${tender_uaid}
  [Documentation]
  ...   ${username} === username
  ...   ${tender_uaid} == tender_uaid
  Selenium2Library.Switch Browser    ${username}
  publicbid.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Selenium2Library.Capture Page Screenshot
  Sleep  3
  ${url}=  Get Element Attribute  id=mForm:participationLink@href
  [return]  ${url}

Змінити цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  Log Many  @{ARGUMENTS}
  Пошук цінової пропозиції  ${ARGUMENTS[0]}  ${ARGUMENTS[1]}
  Input Text  xpath=//*[@id="mForm:data:amount"]  ${ARGUMENTS[3]}
  Click Element  xpath=//*[text()='Зберегти']
  Sleep  5

Завантажити документ в ставку
  [Arguments]  @{ARGUMENTS}
  Log Many  @{ARGUMENTS}
  Пошук цінової пропозиції  ${ARGUMENTS[0]}  ${ARGUMENTS[1]}
  Selenium2Library.Capture Page Screenshot
  Choose File       xpath=//input[@id="mForm:data:tFile_input"]    ${ARGUMENTS[1]}
  Sleep  3
  Selenium2Library.Capture Page Screenshot
  Wait Until Page Contains Element    xpath=//*[text()='Картка документу']  10
  Click Element  id=mForm:docCard:dcType_label
  Wait Until Page Contains Element  id=mForm:docCard:dcType_panel  10
  Click Element  xpath=//*[@id="mForm:docCard:dcType_1"]
  Click Element  xpath=//*[@id="mForm:docCard:docCard"]/table/tfoot/tr/td/button[1]
  Sleep  4
  Execute JavaScript  window.scrollTo(0,0)
  Click Element  id=mForm:proposalSaveBtn
  ${return_value}=  Get Text  xpath=//*[@id="mForm:data:pnlFilesT"]/div/div/div/table/tbody/tr[1]/td[1]/span
  Click Element  id=mForm:data:nBid
  Sleep  3
  [return]  ${return_value}

Змінити документ в ставці
  [Arguments]  @{ARGUMENTS}
  Log Many  @{ARGUMENTS}
  Пошук цінової пропозиції  ${ARGUMENTS[0]}
  Click Element  xpath=//*[@id="mForm:data:pnlFilesT"]/div/div/div/table/tbody/tr[1]/td[5]/button[2]
  Sleep  1
  Click Element  xpath=//div[contains(@class, "ui-confirm-dialog") and @aria-hidden="false"]//span[text()="Так"]
  Sleep  1
  Choose File       xpath=//input[@id="mForm:data:tFile_input"]    ${ARGUMENTS[1]}
  Sleep  3
  Selenium2Library.Capture Page Screenshot
  Wait Until Page Contains Element    xpath=//*[text()='Картка документу']  10
  Click Element  id=mForm:docCard:dcType_label
  Wait Until Page Contains Element  id=mForm:docCard:dcType_panel  10
  Click Element  xpath=//*[@id="mForm:docCard:dcType_1"]
  Click Element  xpath=//*[@id="mForm:docCard:docCard"]/table/tfoot/tr/td/button[1]
  Sleep  4
  Execute JavaScript  window.scrollTo(0,0)
  Click Element  id=mForm:proposalSaveBtn
  ${return_value}=  Get Text  xpath=//*[@id="mForm:data:pnlFilesT"]/div/div/div/table/tbody/tr[1]/td[1]/span
  Click Element  id=mForm:data:nBid
  Sleep  3
  [return]  ${return_value}

