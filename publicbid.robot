*** Settings ***
Library  Selenium2Screenshots
Library  String
Library  DateTime

*** Variables ***
${mail}          test@mail.com
${telephone}     +380976535447
${bid_status}

${tender_title}

${new_description}  Новое описание тендера

*** Keywords ***
Підготувати клієнт для користувача
  [Arguments]  @{ARGUMENTS}
  [Documentation]  Відкрити браузер, створити об’єкт api wrapper, тощо
  ...      ${ARGUMENTS[0]} ==  username
  Open Browser   ${USERS.users['${ARGUMENTS[0]}'].homepage}   ${USERS.users['${username}'].browser}   alias=${ARGUMENTS[0]}
  Set Window Size   @{USERS.users['${ARGUMENTS[0]}'].size}
  Set Window Position   @{USERS.users['${ARGUMENTS[0]}'].position}
  Run Keyword If   '${ARGUMENTS[0]}' != 'Publicbid_Viewer'   Вхід

Вхід
  Run Keyword And Ignore Error   Wait Until Page Contains Element    xpath=//*[@id="mForm:j_idt30"]/tbody/tr[2]/td[7]/a   10
  Click Element                      xpath=//*[@id="mForm:j_idt30"]/tbody/tr[2]/td[7]/a
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
  ${prepared_tender_data}=   Add_data_for_GUI_FrontEnds   ${ARGUMENTS[1]}
  ${items}=         Get From Dictionary   ${prepared_tender_data.data}               items
  ${title}=         Get From Dictionary   ${prepared_tender_data.data}               title
  ${description}=   Get From Dictionary   ${prepared_tender_data.data}               description
  ${budget}=        Get From Dictionary   ${prepared_tender_data.data.value}         amount
  ${step_rate}=     Get From Dictionary   ${prepared_tender_data.data.minimalStep}   amount
  ${countryName}=   Get From Dictionary   ${prepared_tender_data.data.procuringEntity.address}       countryName
  ${item_description}=  Get From Dictionary  ${items[0]}  description
  ${delivery_end_date}=      Get From Dictionary   ${items[0].deliveryDate}   endDate
  ${delivery_end_date}=      convert_datetime_to_dot_format  ${delivery_end_date}
  ${cpv}=           Convert To String     "Картонки"
  ${cpv_id}=           Get From Dictionary   ${items[0].classification}         id
  ${cpv_id_1}=           Get Substring    ${cpv_id}   0   3
  ${dkpp_desc}=     Get From Dictionary   ${items[0].additionalClassifications[0]}   description
  ${dkpp_id}=       Get From Dictionary   ${items[0].additionalClassifications[0]}  id
  ${code}=           Get From Dictionary   ${items[0].unit}          code
  ${quantity}=      Get From Dictionary   ${items[0]}                        quantity
  ${name}=      Get From Dictionary   ${prepared_tender_data.data.procuringEntity.contactPoint}       name

  Selenium2Library.Switch Browser     ${ARGUMENTS[0]}
  Wait Until Page Contains Element    xpath=//*[contains(@class, 'ui-button-text ui-c')][./text()='Нова закупівля']   10
  Click Element                       xpath=//*[contains(@class, 'ui-button-text ui-c')][./text()='Нова закупівля']
  Wait Until Page Contains Element    id=mForm:data:name
  Input text                          id=mForm:data:name     ${title}
  Input text                          id=mForm:data:desc     ${description}
  Input text                          id=mForm:data:budget   ${budget}
  Input text                          id=mForm:data:step     ${step_rate}
  Click Element                       xpath=//*[@id='mForm:data:vat']/tbody/tr/td[1]//span
  Input text                          id=mForm:data:dEPr_input    ${delivery_end_date}
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
  Input text                          id=mForm:data:rName    ${name}
  Input text                          id=mForm:data:rPhone    ${telephone}
  Input text                          id=mForm:data:rMail   ${mail}
  Choose File                         id=mForm:data:docFile_input     ${file_path}
  Sleep  2
  Run Keyword if   '${mode}' == 'multi'   Додати предмет   items
  # Save
  Click Element                       id=mForm:bSave
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

  :FOR    ${INDEX}    IN RANGE    1    12
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
  sleep  3
  Input Text   xpath=//*[@id="mForm:datalist:nBidClmn"]/div/input  ${ARGUMENTS[1]}
  Press Key  xpath=//*[@id="mForm:datalist:nBidClmn"]/div/input  \\13
  sleep  10
#  ${last_note_id}=  Add pointy note   xpath=//*[@id="mForm:datalist_data"]/tr[1]/td[2]/a   Found tender with tenderID "${ARGUMENTS[1]}"   width=200  position=bottom
#  sleep  1
#  Remove element   ${last_note_id}
  Click Link    xpath=//*[@id="mForm:datalist_data"]/tr[1]/td[2]/a
  Wait Until Page Contains    ${ARGUMENTS[1]}   10
  sleep  1
  Capture Page Screenshot

Отримати інформацію із тендера
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  fieldname
  Switch browser   ${ARGUMENTS[0]}
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
  #Нужно преобразовать дату в верный формат
  [return]  ${return_value}

Отримати інформацію про tenderPeriod.startDate
  ${return_value}=  Get Value           xpath=//*[@id="mForm:data:dSPr_input"]
  #Нужно преобразовать дату в верный формат
  [return]  ${return_value}

Отримати інформацію про tenderPeriod.endDate
  ${return_value}=  Get Value           xpath=//*[@id="mForm:data:dEPr_input"]
  #Нужно преобразовать дату в верный формат
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
  Run Keyword If  '${tender_status}' == 'Період уточнень'  Input text  xpath=//*[@id="mForm:data:desc"]  ${new_description}
  Click Element              xpath=//*[@id="mForm:bSave"]
  Sleep  10
  Capture Page Screenshot

Отримати інформацію про items[0].description
  ${return_value}=  Get Text           xpath=//*[@id="mForm:data:subject0"]
  [return]  ${return_value}

Отримати інформацію про items[0].deliveryDate.endDate
  ${return_value}=  Get Value           xpath=//*[@id="mForm:data:delDE0_input"]
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
  ${return_value}=  Get Value           xpath=//*[@id="mForm:data:cCpvGr_input"]
  [return]  ${return_value}

Отримати інформацію про items[0].classification.id
  ${return_value}=  Get Value           xpath=//*[@id="mForm:data:cCpv0_input"]
  [return]  ${return_value}

Отримати інформацію про items[0].classification.description
  ${return_value}=  Get Text           xpath=//*[@id="mForm:data:nCpv0"]
  [return]  ${return_value}

Отримати інформацію про items[0].additionalClassifications[0].scheme
  ${return_value}=  Get Value           xpath=//*[@id="mForm:data:cDkpp0_input"]
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

Отримати інформацію про questions[0].answer
    ${return_value}=  Get Text  xpath=//*[@id="mForm:data_data"]/tr[1]/td[1]/span
    [return]  ${return_value}







