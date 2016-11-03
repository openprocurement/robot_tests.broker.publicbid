*** Settings ***
Library  Selenium2Library
Library  String
Library  DateTime
Library  publicbid_json_util.py
Library  publicbid_service.py
Library  op_robot_tests.tests_files.service_keywords

*** Variables ***
${mail}          test_test@test.com
${telephone}     +380630000000
${bid_number}

*** Keywords ***
Підготувати дані для оголошення тендера
  [Arguments]  @{ARGUMENTS}
  ${adapted_data}=  adapt_data  ${ARGUMENTS[1]}
  Log Many  @{ARGUMENTS}
  [Return]  ${adapted_data}


Підготувати клієнт для користувача
  [Arguments]  @{ARGUMENTS}
  [Documentation]  Відкрити браузер, створити об’єкт api wrapper, тощо
  ...      ${ARGUMENTS[0]} ==  username
  Log  ${USERS.users['${ARGUMENTS[0]}'].homepage}
  Log  ${USERS.users['${ARGUMENTS[0]}'].browser}
  Open Browser  ${USERS.users['${ARGUMENTS[0]}'].homepage}  ${USERS.users['${ARGUMENTS[0]}'].browser}  alias=${ARGUMENTS[0]}
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
  ${present}=  Run Keyword And Return Status    Element Should Be Visible   id=mForm:existNotResolvedQuestionsOrAppealsDialog
  Run Keyword If  ${present}  Click Element  xpath=//*[@id='mForm:existNotResolvedQuestionsOrAppealsDialog']/div[3]/a
  Sleep  4
  Click Element  xpath=//*[text()='Електронні торги']
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
  ${dgfID}=  Get From Dictionary  ${prepared_tender_data}  dgfID
  ${budget}=        get_budget   ${prepared_tender_data}
  ${step_rate}=     get_step_rate  ${prepared_tender_data}
  ${auctionPeriod}=  Get From Dictionary  ${prepared_tender_data}  auctionPeriod
  ${auctionPeriod_start_date}=  publicbid_service.convert_date_to_string  ${auctionPeriod.startDate}
  ${countryName}=   Get From Dictionary   ${prepared_tender_data.procuringEntity.address}       countryName
  ${item_description}=  Get From Dictionary  ${items[0]}  description
  ${item_locality}=  Get From Dictionary  ${items[0].deliveryAddress}  locality
  ${guarantee}=  Get From Dictionary  ${prepared_tender_data}  guarantee
  ${item_delivery_address_street_address}=  Get From Dictionary  ${items[0].deliveryAddress}  streetAddress
  ${item_delivery_postal_code}=  Get From Dictionary  ${items[0].deliveryAddress}  postalCode
  ${cav_id}=           Get From Dictionary   ${items[0].classification}  id
  ${code}=           Get From Dictionary   ${items[0].unit}          code
  ${quantity}=      Get From Dictionary   ${items[0]}                        quantity
  ${name}=      Get From Dictionary   ${prepared_tender_data.procuringEntity.contactPoint}       name
  ${dkpp_id}=  Convert To String  1.13

  Selenium2Library.Switch Browser     ${ARGUMENTS[0]}
  Wait Until Page Contains Element    xpath=//*[text()='ОГОЛОСИТИ ЕЛЕКТРОННІ ТОРГИ']   10
  Click Element                       xpath=//*[text()='ОГОЛОСИТИ ЕЛЕКТРОННІ ТОРГИ']
  Wait Until Page Contains Element    id=mForm:procurementType_label  10
  Click Element                       id=mForm:procurementType_label
  ${procurement_type}=  get from dictionary  ${prepared_tender_data}  procurementMethodType
  Log  ${procurement_type}
  Run Keyword If  '${procurement_type}' == 'dgfFinancialAssets'  Click Element  id=mForm:procurementType_0
  ...             ELSE  Click Element  id=mForm:procurementType_1
  Sleep  3
  Click Element                       id=mForm:chooseProcurementTypeBtn
  Wait Until Page Contains Element    id=mForm:name  10
  Input Text  id=mForm:dgfID  ${dgfID}
  Input text                          id=mForm:name     ${title}
  Input text                          id=mForm:desc     ${description}
  Input text                          id=mForm:budget   ${budget}
  Sleep  7
  Input text                          id=mForm:step     ${step_rate}
  ${guarantee_amount}=  Convert To String  ${guarantee.amount}
  Input text                          id=mForm:guaranteeAmount  ${guarantee_amount}
  Click Element                       id=mForm:guaranteeCurrency_label
  Click Element                       id=mForm:guaranteeCurrency_1
  Input text                          xpath=//*[@id="mForm:dStart_input"]  ${auctionPeriod_start_date}
  Click Element                       xpath=//*[@id="mForm:vat"]/tbody/tr/td[1]/div/div[2]/span
  Input text                          id=mForm:bidItem_0:subject    ${item_description}
  Input text                          id=mForm:bidItem_0:cCpv_input   ${cav_id}
  Wait Until Page Contains Element    xpath=//div[@id='mForm:bidItem_0:cCpv_panel']//td[1]/span   10
  Click Element                       xpath=//div[@id='mForm:bidItem_0:cCpv_panel']//td[1]/span
  Input text                          id=mForm:bidItem_0:unit_input    ${code}
  Wait Until Page Contains Element    xpath=//div[@id='mForm:bidItem_0:unit_panel']//tr/td[1]   10
  Click Element                       xpath=//div[@id='mForm:bidItem_0:unit_panel']//tr/td[1]
  Input text                          id=mForm:bidItem_0:amount   ${quantity}
  Click Element                       xpath=//*[@id="mForm:bidItem_0:cReg"]/div[3]
  Sleep  1
  Click Element                       xpath=//ul[@id="mForm:bidItem_0:cReg_items"]/li[text()="м.Київ"]
  Sleep  1
  Input Text                       xpath=//*[@id="mForm:bidItem_0:cTer_input"]  ${item_locality}
  Sleep  2
  Click Element                       xpath=//*[@id="mForm:bidItem_0:cTer_panel"]/ul/li[1]
  Sleep  1
  Input text                          id=mForm:bidItem_0:zc  ${item_delivery_postal_code}
  Input text                          xpath=//*[@id="mForm:bidItem_0:delAdr"]  ${item_delivery_address_street_address}
  Input text                          id=mForm:rName    ${name}
  Input text                          id=mForm:rPhone    ${telephone}
  Input text                          id=mForm:rMail   ${mail}
  Завантажити документ до тендеру  ${file_path}  doc
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
  \  Exit For Loop If  '${bid_status}' == 'Очікування пропозицій'
  \  Sleep  3
  \  ${bid_status}=  Get Text  xpath=//*[@id="mForm:status"]
  \  Run Keyword If  '${bid_status}' != 'Очікування пропозицій'  Sleep  15
  \  Run Keyword If  '${bid_status}' != 'Очікування пропозицій'  Reload Page

  ${tender_UAid}=  Get Text           id=mForm:nBid
  ${tender_UAid}=  Get Substring  ${tender_UAid}  19
  ${Ids}       Convert To String  ${tender_UAid}
  Run keyword if   '${mode}' == 'multi'   Set Multi Ids   ${tender_UAid}
  [Return]  ${Ids}

Завантажити документ до тендеру
  [Arguments]   ${file}  ${type}
  Log  ${file}
  Log  ${type}
  Choose File       id=mForm:docFile_input     ${file}
  Sleep  2
  Selenium2Library.Capture Page Screenshot
  Wait Until Page Contains Element    xpath=//*[text()='Картка документу']  10
  Click Element  id=mForm:docCard:dcType_label
  Wait Until Page Contains Element  id=mForm:docCard:dcType_panel  10
  Run Keyword If  '${type}' == 'img'  Click Element  xpath=//*[@id="mForm:docCard:dcType_1"]
  Run Keyword If  '${type}' == 'doc'  Click Element  xpath=//*[@id="mForm:docCard:dcType_14"]
  Click Element  xpath=//*[@id="mForm:docCard:docCard"]/table/tfoot/tr/td/button[1]
  Selenium2Library.Capture Page Screenshot
  Sleep  5

Завантажити документ
  [Arguments]   ${username}  ${file}  ${tender_uaid}
  Log  ${username}
  Log  ${file}
  Log  ${tender_uaid}
  Завантажити документ до тендеру  ${file}  doc
  Execute JavaScript  window.scrollTo(0,0)
  Click Element  xpath=//*[@id="mForm:bSave"]
  Sleep  5

Завантажити ілюстрацію
  [Arguments]  ${username}  ${tender_uaid}  ${file}
  Log  ${username}
  Log  ${file}
  Log  ${tender_uaid}
  Завантажити документ до тендеру  ${file}  img
  Execute JavaScript  window.scrollTo(0,0)
  Click Element  xpath=//*[@id="mForm:bSave"]
  Sleep  10

Додати Virtual Data Room
  [Arguments]  ${username}  ${tender_uaid}  ${vdr_link}
  Log  ${username}
  Log  ${tender_uaid}
  Log  ${vdr_link}
  Click Element  xpath=//*[text()='Додати посилання на VDR']
  Sleep  2
  Wait Until Page Contains Element    xpath=//*[text()='Картка документу']  10
  Click Element  id=mForm:docCard:dcType_label
  Wait Until Page Contains Element  id=mForm:docCard:dcType_panel  10
  Click Element  xpath=//*[@id="mForm:docCard:dcType_1"]
  Input Text  id=mForm:docCard:fileName  ${vdr_link}
  Input Text  id=mForm:docCard:extUrl  ${vdr_link}
  Click Element  xpath=//*[@id="mForm:docCard:docCard"]/table/tfoot/tr/td/button[1]
  Selenium2Library.Capture Page Screenshot
  Sleep  5

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
  Input text                         id=mForm:cCpv1_input   ${cav_id}
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
  Input text                         id=mForm:cCpv2_input   ${cav_id}
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
  Input text                         id=mForm:cCpv3_input   ${cav_id}
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
  Click Element  xpath=//a[./text()="Електронні торги"]
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
  Log Many  @{ARGUMENTS}
  Switch browser   ${ARGUMENTS[0]}
  Log  ${TENDER['TENDER_UAID']}
  Run Keyword And Return  Отримати інформацію про ${ARGUMENTS[2]}

Отримати інформацію про value.currency
  ${return_value}=  Get Text  id=mForm:currency_label
  ${return_value}=  Convert To String  UAH
  [Return]  ${return_value}

Отримати інформацію про value.valueAddedTaxIncluded
  ${return_value}=  Convert To Boolean  True
  [Return]  ${return_value}

Отримати інформацію про title
  ${return_value}=   Get Text  xpath=//*[@id="mForm:name"]
  [Return]  ${return_value}

Отримати інформацію про description
  ${return_value}=   Get Text  xpath=//*[@id="mForm:desc"]
  [Return]  ${return_value}

Отримати інформацію про value.amount
  ${return_value}=   Get Value  xpath=//*[@id="mForm:budget"]
  Log  ${return_value}
  ${return_value}=   Convert To Number   ${return_value}
  [Return]  ${return_value}

Отримати інформацію про auctionID
  ${return_value}=  Get Text           id=mForm:nBid
  ${return_value}=  Get Substring  ${return_value}  19
  ${return_value}=  Convert To String  ${return_value}
  [Return]  ${return_value}

Отримати інформацію про procuringEntity.name
  ${return_value}=  Get Text           xpath=//*[@id="mForm:orgName"]
  [Return]  ${return_value}

Отримати інформацію про enquiryPeriod.startDate
  ${return_value}=  Get Text           xpath=//*[@id="mForm:da"]
  Fail  "Особливість реалізації, дата початку періоду уточнень = даті оголошення закупівлі"
  [Return]  ${return_value}

Отримати інформацію про enquiryPeriod.endDate
  ${return_value}=  Get Value           xpath=//*[@id="mForm:dEPr_input"]
  ${return_value}=  publicbid_service.parse_date  ${return_value}
  [Return]  ${return_value}

Отримати інформацію про tenderPeriod.startDate
  ${return_value}=  Get Text           xpath=//*[@id="mForm:da"]
  ${return_value}=  publicbid_service.parse_date  ${return_value}
  [Return]  ${return_value}

Отримати інформацію про tenderPeriod.endDate
  ${return_value}=  Get Value           xpath=//*[@id="mForm:dEPr_input"]
  ${return_value}=  publicbid_service.parse_date  ${return_value}
  [Return]  ${return_value}

Отримати інформацію про minimalStep.amount
  ${return_value}=  Get Value           xpath=//*[@id="mForm:step"]
  ${return_value}=  Convert To Number  ${return_value}
  [Return]  ${return_value}

Отримати інформацію про auctionPeriod.startDate
  ${return_value}=  Get Value           xpath=//*[@id="mForm:dStart_input"]
  ${return_value}=  publicbid_service.parse_date  ${return_value}
  [Return]  ${return_value}

Отримати інформацію із предмету
  [Arguments]  @{ARGUMENTS}
  Log Many  @{ARGUMENTS}
  ${result}=  Run Keyword If  ${ARGUMENTS[3]} == 'description'  Get Text  xpath=//[@id="mForm:bidItem_0:subject"]
  [Return]  ${result}

Внести зміни в тендер
  [Arguments]  ${username}  ${tender_uaid}  ${field}  ${value}
  Selenium2Library.Switch Browser    ${username}
  publicbid.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Wait Until Page Contains Element   xpath=//*[@id="mForm:status"]   10
  ${field_id}=  publicbid_service.get_field_id  ${field}
  ${field_value}=  publicbid_service.get_field_value  ${field}  ${value}
  Input Text  id=${field_id}  ${field_value}
  Sleep  3
  Click Element              xpath=//*[@id="mForm:bSave"]
  Sleep  3

Отримати інформацію про items[0].description
  ${return_value}=  Get Text           xpath=//*[@id="mForm:bidItem_0:subject"]
  [Return]  ${return_value}

Отримати інформацію про items[0].deliveryDate.endDate
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:item0"]/tbody/tr[5]/td[4]/input
  ${return_value}=  publicbid_service.parse_item_date  ${return_value}
  [Return]  ${return_value}

Отримати інформацію про items[0].deliveryLocation.latitude
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:delLoc1"]
  Run Keyword And Return  Convert To Number  ${return_value}

Отримати інформацію про items[0].deliveryLocation.longitude
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:delLoc2"]
  Run Keyword And Return  Convert To Number  ${return_value}

Отримати інформацію про items[0].deliveryAddress.countryName
  ${return_value}=  Get Text           xpath=//*[@id="mForm:bidItem_0:nState"]
  ${return_value}=  capitalize_first_letter  ${return_value}
  [Return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.postalCode
  ${postal_code_1_exitsts}=  Run Keyword And Return Status  Page Should Contain Element  xpath=//*[@id="mForm:bidItem_0:zc"]
  ${postal_code}=  Run Keyword If  ${postal_code_1_exitsts}  Get Value  xpath=//*[@id="mForm:bidItem_0:zc"]
  ...         ELSE  Get Value  xpath=//*[@id="mForm:bidItem_0:zcText"]
  [Return]  ${postal_code}

Отримати інформацію про items[0].deliveryAddress.region
  ${region_1_exitsts}=  Run Keyword And Return Status  Page Should Contain Element  xpath=//*[@id="mForm:bidItem_0:cReg_label"]
  ${region}=  Run Keyword If  ${region_1_exitsts}  Get Text  xpath=//*[@id="mForm:bidItem_0:cReg_label"]
  ...         ELSE  Get Value  xpath=//*[@id="mForm:bidItem_0:cRegText"]
  [Return]  ${region}

Отримати інформацію про items[0].deliveryAddress.locality
  ${ter_1_exitsts}=  Run Keyword And Return Status  Page Should Contain Element  xpath=//*[@id="mForm:bidItem_0:cTer_input"]
  ${ter}=  Run Keyword If  ${ter_1_exitsts}  Get Value  xpath=//*[@id="mForm:bidItem_0:cTer_input"]
  ...         ELSE  Get Value  xpath=//*[@id="mForm:bidItem_0:cTerText"]
  [Return]  ${ter}

Отримати інформацію про items[0].deliveryAddress.streetAddress
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:delAdr"]
  [Return]  ${return_value}

Отримати інформацію про items[0].classification.scheme
  ${return_value}=  Get Text           xpath=//*[@id="mForm:bidItem_0:item0"]/tbody/tr[2]/td/label
  ${return_value}=  Get Substring  ${return_value}  4  7
  ${return_value}=  Convert To String  ${return_value}
  [Return]  ${return_value}

Отримати інформацію про items[0].classification.id
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:cCpv_input"]
  ${return_value}=  Get Substring  ${return_value}  0  10
  [Return]  ${return_value}

Отримати інформацію про items[0].classification.description
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:cCpv_input"]
  ${return_value}=  Get Substring  ${return_value}  11
  [Return]  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].scheme
  ${return_value}=  Get Text           xpath=//*[@id="mForm:bidItem_0:item0"]/tbody/tr[3]/td[3]/label
  ${return_value}=  Get Substring  ${return_value}  36  40
  ${return_value}=  Convert To String  ${return_value}
  [Return]  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].id
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:cDkpp_input"]
  [Return]  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].description
  ${return_value}=  Get Text           xpath=//*[@id="mForm:bidItem_0:nDkpp"]
  ${return_value}=  Strip String  ${return_value}
  [Return]  ${return_value}

Отримати інформацію про items[0].unit.name
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:unit_input"]
  ${return_value}=  Get Substring  ${return_value}  4
  ${return_value}=  Convert To String  ${return_value}
  [Return]  ${return_value}

Отримати інформацію про items[0].unit.code
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:unit_input"]
  ${return_value}=  Get Substring  ${return_value}  0  3
  ${return_value}=  Convert To String  ${return_value}
  [Return]  ${return_value}

Отримати інформацію про items[0].quantity
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_0:amount"]
  ${return_value}=  Convert To Number  ${return_value}
  [Return]  ${return_value}

Отримати інформацію про status
  Capture Page Screenshot
  Reload Page
  ${return_value}=  Get Text  xpath=//*[@id="mForm:status"]
  ${return_value}=  get_tender_code  ${return_value}
  ${return_value}=  Convert To String  ${return_value}
  [Return]  ${return_value}

Отримати інформацію про dgfID
  ${return_value}=  Get Text  id=mForm:dgfID
  [Return]  ${return_value}


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
  Execute JavaScript  window.scrollTo(0,0)
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
  [Return]  ${return_value}

Отримати інформацію про questions[0].description
  ${return_value}=  Get Text  xpath=//*[@id="mForm:data_data"]/tr[1]/td[1]/span[2]
  [Return]  ${return_value}

Отримати інформацію про questions[0].date
  ${return_value}=  Get Text  xpath=//*[@id="mForm:data_data"]/tr/td[4]
  ${return_value}=  publicbid_service.parse_date  ${return_value}
  [Return]  ${return_value}

Отримати інформацію про questions[0].answer
  Click Element  xpath=//*[text()="Обговорення"]
  Sleep  5
  ${return_value}=  Get Text  xpath=//*[@id="mForm:data_data"]/tr[2]/td[1]/span[2]
  [Return]  ${return_value}

Отримати інформацію про auctionPeriod.endDate
  Capture Page Screenshot
  ${return_value}=  Get Text  xpath=//*[@id="mForm:auctionEndDate"]
  ${return_value}=  publicbid_service.parse date  ${return_value}
  [Return]  ${return_value}

Подати цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} ==  ${test_bid_data}
  log many  @{ARGUMENTS}
  ${amount}=  Get From Dictionary   ${ARGUMENTS[2].data.value}  amount
  publicbid.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  ${tender_status}=  Get Text  xpath=//*[@id="mForm:status"]
  Run Keyword If  '${tender_status}' == 'Період уточнень'  Fail  "Неможливо подати цінову пропозицію в період уточнень"
  Click Element  xpath=//*[text()='Подати пропозицію']
  Sleep  2
  ${amount}=  convert to string  ${amount}
  Input Text  xpath=//*[@id="mForm:amount"]  ${amount}
  ${financial_license_path}  ${file_title}  ${file_content}=  create_fake_doc
  choose file  id=mForm:qFile_input  ${financial_license_path}
  Wait Until Page Contains Element    xpath=//*[text()='Картка документу']  10
  Click Element  id=mForm:docCard:dcType_label
  Wait Until Page Contains Element  id=mForm:docCard:dcType_panel  10
  Click Element  id=mForm:docCard:dcType_3
  Click Element  xpath=//*[@id="mForm:docCard:docCard"]/table/tfoot/tr/td/button[1]
  Sleep  2
  Input Text  xpath=//*[@id="mForm:rName"]  Тестовий закупівельник
  Input Text  xpath=//*[@id="mForm:rPhone"]  ${telephone}
  Input Text  xpath=//*[@id="mForm:rMail"]  ${mail}
  Execute JavaScript  window.scrollTo(0,0)
  Click Element  xpath=//*[text()='Зберегти']
  Wait Until Page Contains Element  xpath=//*[@id="mForm:proposalSaveInfo"]/div[3]/button  10
  Sleep  2
  Click Element  xpath=//*[@id="mForm:proposalSaveInfo"]/div[3]/button
  Sleep  2
  Click Element  xpath=//*[text()='Зареєструвати пропозицію']
  Sleep  5
  ${bid_number}=  Get Text  xpath=//*[@id="mForm:data"]/table/tbody/tr[3]/td[2]
  Selenium2Library.Capture Page Screenshot
  Sleep  60
  [Return]  ${bid_number}

Отримати інформацію із пропозиції
  [Arguments]  @{ARGUMENTS}
  log many  @{ARGUMENTS}
  ${return_value}=  get value  id=mForm:amount
  ${return_value}=  convert to number  ${return_value}
  Capture Page Screenshot
  [Return]  ${return_value}

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
  Click Element  xpath=//*[@id="mForm:proposalList:0:asdasd"]/div[1]/div/span[1]/a
  Sleep  5


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
  [Arguments]  ${username}  ${bid_number}  @{ARGUMENTS}
  Selenium2Library.Switch Browser    ${username}
  publicbid.Пошук тендера по ідентифікатору  ${username}  ${bid_number}
  Selenium2Library.Capture Page Screenshot
  Sleep  3
  ${url}=  Get Element Attribute  id=mForm:auctionLink@href
  [Return]  ${url}

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
  [Return]  ${url}

Змінити цінову пропозицію
  [Arguments]  ${username}  ${bid_number}  ${field}  ${new_amount}
  Пошук цінової пропозиції  ${username}  ${bid_number}
  ${new_amount}=  convert to string  ${new_amount}
  Input Text  xpath=//*[@id="mForm:amount"]  ${new_amount}
  Click Element  xpath=//*[text()='Зберегти']
  Sleep  5

Завантажити документ в ставку
  [Arguments]  ${username}  ${file_path}  ${bid_number}
  Пошук цінової пропозиції  ${username}  ${bid_number}
  Selenium2Library.Capture Page Screenshot
  Choose File       xpath=//input[@id="mForm:qFile_input"]    ${file_path}
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
  ${return_value}=  Get Text  xpath=//*[@id="mForm:pnlFilesQ"]/div/div/div/table/tbody/tr[1]/td[1]/a
  Sleep  3
  [Return]  ${return_value}

Змінити документ в ставці
  [Arguments]  @{ARGUMENTS}
  Log Many  @{ARGUMENTS}
  Пошук цінової пропозиції  ${ARGUMENTS[0]}
  Click Element  xpath=//*[@id="mForm:pnlFilesQ""]/div/div/div/table/tbody/tr[1]/td[5]/button[2]
  Sleep  1
  Click Element  xpath=//div[contains(@class, "ui-confirm-dialog") and @aria-hidden="false"]//span[text()="Так"]
  Sleep  1
  Choose File       xpath=//input[@id="mForm:qFile_input"]    ${ARGUMENTS[1]}
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
  ${return_value}=  Get Text  xpath=//*[@id="mForm:pnlFilesQ"]/div/div/div/table/tbody/tr[1]/td[1]/a
  Sleep  3
  [Return]  ${return_value}

Підтвердити підписання контракту
  [Arguments]  @{ARGUMENTS}
  log many  @{ARGUMENTS}
  Sleep  60
  Click Element  xpath=//*[text()='Результати аукціону']
  Wait Until Page Contains Element  xpath=//*[text()='Учасники аукціону']  10
  Click Element  xpath=//*[text()='Учасники аукціону']
  Sleep  3
  Click Element  xpath=//*[text()='Оформити договір']
  Wait Until Page Contains Element  xpath=//*[text()='Оцінка']  10
  ${current_date}=  Get Current Date
  ${current_date}=  publicbid_service.convert_date_to_string  ${current_date}
  ${financial_license_path}  ${file_title}  ${file_content}=  create_fake_doc
  Choose File  id=mForm:contract-signed-upload-input_input  ${financial_license_path}
  Wait Until Page Contains Element    xpath=//*[text()='Картка документу']  10
  Click Element  id=mForm:docCard:dcType_label
  Wait Until Page Contains Element  id=mForm:docCard:dcType_panel  10
  Click Element  xpath=//*[@id="mForm:docCard:dcType_2"]
  Click Element  xpath=//*[@id="mForm:docCard:docCard"]/table/tfoot/tr/td/button[1]
  Sleep  2
  Execute JavaScript  window.scrollTo(0,0)
  Input text  xpath=//*[@id="mForm:dc_input"]  ${current_date}
  Input text  xpath=//*[@id="mForm:contractNumber"]  123456
  Click Element  id=mForm:bS
  Sleep  15
  Click Element  id=mForm:bS2
  Click Element  id=mForm:yes-btn
  Sleep  3
  Capture Page Screenshot


Підтвердити постачальника
  [Arguments]  @{ARGUMENTS}
  log many  @{ARGUMENTS}
  Sleep  120
  Click Element  xpath=//*[text()='Результати аукціону']
  Wait Until Page Contains Element  xpath=//*[text()='Учасники аукціону']  10
  Click Element  xpath=//*[text()='Учасники аукціону']
  Sleep  3
  Click Element  xpath=//*[text()='Оцінити']
  Sleep  3
  Click Element  id=mForm:bW
  Click Element  xpath=//*[@id="mForm:confirm-dialog"]/div[3]/button[1]
  Sleep  1
  Click Element  id=mForm:bRS
  Capture Page Screenshot


Отримати інформацію із запитання
  [Arguments]  ${username}  ${tender_uaid}  ${question_id}  ${field}
  Execute JavaScript  window.scrollTo(0,0)
  Click Element  xpath=//span[./text()='Обговорення']
  ${question_element_id}=  Get Element Attribute  xpath=//span[starts-with(., '${question_id}')]@style
  Log  ${question_element_id}
