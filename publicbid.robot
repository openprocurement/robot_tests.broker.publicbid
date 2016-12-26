*** Settings ***
Library  Selenium2Library
Library  String
Library  DateTime
Library  publicbid_json_util.py
Library  publicbid_service.py
Library  op_robot_tests.tests_files.service_keywords
Resource  view.robot

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
  ${present}=  Run Keyword And Return Status    Element Should Be Visible   id=mForm:existNotResolvedQuestionsOrAppealsDiaLog
  Run Keyword If  ${present}  Click Element  xpath=//*[@id='mForm:existNotResolvedQuestionsOrAppealsDiaLog']/div[3]/a
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
  ${guarantee}=  Get From Dictionary  ${prepared_tender_data}  guarantee
  ${dgfID}=  Get From Dictionary  ${prepared_tender_data}  dgfID
  ${dgfDecisionDate}=  Get From Dictionary  ${prepared_tender_data}  dgfDecisionDate
  ${dgfDecisionID}=  Get From Dictionary  ${prepared_tender_data}  dgfDecisionID
  ${budget}=        get_budget   ${prepared_tender_data}
  ${step_rate}=     get_step_rate  ${prepared_tender_data}
  ${auctionPeriod}=  Get From Dictionary  ${prepared_tender_data}  auctionPeriod
  ${auctionPeriod_start_date}=  publicbid_service.convert_date_to_string  ${auctionPeriod.startDate}
  ${countryName}=   Get From Dictionary   ${prepared_tender_data.procuringEntity.address}       countryName
  ${name}=      Get From Dictionary   ${prepared_tender_data.procuringEntity.contactPoint}       name
  ${dkpp_id}=  Convert To String  1.13
  ${tenderAttemptXpath}=  publicbid_service.get_tender_attempts_xpath  ${prepared_tender_data}

  Switch Browser     ${ARGUMENTS[0]}
  Wait Until Page Contains Element    xpath=//*[text()='ОГОЛОСИТИ ЕЛЕКТРОННІ ТОРГИ']   10
  Click Element                       xpath=//*[text()='Переглянути тестові електронні торги']
  Wait Until Page Contains Element    xpath=//*[text()='ТЕСТОВИЙ РЕЖИМ']  60
  Click Element                       xpath=//*[text()='ОГОЛОСИТИ ТОРГИ У ТЕСТОВОМУ РЕЖИМІ']
  Wait Until Page Contains Element    id=mForm:procurementType_label  10
  Click Element                       id=mForm:procurementType_label
  ${procurement_type}=  get from dictionary  ${prepared_tender_data}  procurementMethodType
  Log  ${procurement_type}
  Run Keyword If  '${procurement_type}' == 'dgfFinancialAssets'  Click Element  id=mForm:procurementType_0
  ...             ELSE  Click Element  id=mForm:procurementType_1
  Sleep  3
  Click Element                       id=mForm:chooseProcurementTypeBtn
  Wait Until Page Contains Element    id=mForm:name  10
  Input Text                          id=mForm:dgfID  ${dgfID}
  Input text                          id=mForm:name     ${title}
  Input text                          id=mForm:desc     ${description}
  Click Element                       id=mForm:tenderAttempts_label
  Click Element                       xpath=${tenderAttemptXpath}
  Input text                          id=mForm:budget   ${budget}
  Sleep  7
  Input text                          id=mForm:step     ${step_rate}
  ${guarantee_amount}=  Convert To String  ${guarantee.amount}
  Input text                          id=mForm:guaranteeAmount  ${guarantee_amount}
  Click Element                       id=mForm:guaranteeCurrency_label
  Click Element                       id=mForm:guaranteeCurrency_1
  ${dgfDecisionDate}=  publicbid_service.convert_date  ${dgfDecisionDate}  %Y-%m-%d  %d.%m.%Y
  Input Text                          id=mForm:dgfDecisionDate_input   ${dgfDecisionDate}
  Input Text                          id=mForm:dgfDecisionId   ${dgfDecisionID}
  Input text                          xpath=//*[@id="mForm:dStart_input"]  ${auctionPeriod_start_date}
  Click Element                       xpath=//*[@id="mForm:vat"]/tbody/tr/td[1]/div/div[2]/span

  Додати предмети   ${items}

  Input text                          id=mForm:rName    ${name}
  Input text                          id=mForm:rPhone    ${telephone}
  Input text                          id=mForm:rMail   ${mail}
  Sleep  2

  # Save
  Execute JavaScript  window.scrollTo(0,0)
  Click Element                       xpath=//*[@id="mForm:bSave"]
  Wait Until Element Is Visible  id=notifyBar  60
  Sleep  3
  Click Element                       xpath=//*[@id="mForm:needAnnounce"]/div[3]/button/span
  Sleep   5
  # Announce
  Click Element                       xpath=//span[text()="ОГОЛОСИТИ ТОРГИ У ТЕСТОВОМУ РЕЖИМІ"]
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
  Capture Page Screenshot
  Wait Until Page Contains Element    xpath=//*[text()='Картка документу']  10
  Click Element  id=mForm:docCard:dcType_label
  Wait Until Page Contains Element  id=mForm:docCard:dcType_panel  10
  ${doc_type_xpath}=  publicbid_service.get_document_type_xpath  ${type}
  Click Element  xpath=${doc_type_xpath}
  Click Element  xpath=//*[@id="mForm:docCard:docCard"]/table/tfoot/tr/td/button[1]
  Capture Page Screenshot
  Sleep  5

Завантажити документ
  [Arguments]   ${username}  ${file}  ${tender_uaid}
  Log  ${username}
  Log  ${file}
  Log  ${tender_uaid}
  Завантажити документ до тендеру  ${file}  doc
  Execute JavaScript  window.scrollTo(0,0)
  Click Element  xpath=//*[@id="mForm:bSave"]
  Wait Until Element Is Visible  xpath=//*[text()='Збережено!']  120
  Capture Page Screenshot
  Sleep  5

Завантажити ілюстрацію
  [Arguments]  ${username}  ${tender_uaid}  ${file}
  Log  ${username}
  Log  ${file}
  Log  ${tender_uaid}
  Завантажити документ до тендеру  ${file}  illustration
  Execute JavaScript  window.scrollTo(0,0)
  Click Element  xpath=//*[@id="mForm:bSave"]
  Wait Until Element Is Visible  xpath=//*[text()='Збережено!']  120
  Capture Page Screenshot
  Sleep  5

Додати Virtual Data Room
  [Arguments]  ${username}  ${tender_uaid}  ${vdr_link}
  Capture Page Screenshot
  Додати посилання до тендеру  ${vdr_link}  vdr  Посилання на VDR
  Execute JavaScript  window.scrollTo(0,0)
  Click Element  xpath=//*[@id="mForm:bSave"]
  Wait Until Element Is Visible  xpath=//*[text()='Збережено!']  120
  Capture Page Screenshot
  Sleep  5

Set Multi Ids
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${tender_UAid}
  ${id}=           Get Text           id=mForm:nBid
  ${Ids}   Create List    ${tender_UAid}   ${id}

Додати предмети
  [Arguments]  ${items}
  ${items_count}=  Get Length  ${items}
  :FOR  ${index}  IN RANGE  ${items_count}
  \  Log  ${items[${index}]}
  \  Додати предмет  ${items[${index}]}  ${index}

Додати предмет
  [Arguments]  ${item}  ${index}
  Execute JavaScript  window.scrollTo(0,0)
  Run Keyword If  ${index} != 0  Click Element    xpath=//span[text()='Додати актив']
  Capture Page Screenshot

  ${item_description}=  Get From Dictionary  ${item}  description
  ${item_locality}=  Get From Dictionary  ${item.deliveryAddress}  locality
  ${item_delivery_address_street_address}=  Get From Dictionary  ${item.deliveryAddress}  streetAddress
  ${item_delivery_postal_code}=  Get From Dictionary  ${item.deliveryAddress}  postalCode
  ${cav_id}=           Get From Dictionary   ${item.classification}  id
  ${code}=           Get From Dictionary   ${item.unit}          code
  ${quantity}=      Get From Dictionary   ${item}                        quantity


  Input text                          id=mForm:bidItem_${index}:subject    ${item_description}
  Input text                          id=mForm:bidItem_${index}:cCpv_input   ${cav_id}
  Wait Until Page Contains Element    xpath=//div[@id='mForm:bidItem_${index}:cCpv_panel']//td[1]/span   10
  Click Element                       xpath=//div[@id='mForm:bidItem_${index}:cCpv_panel']//td[1]/span
  Input text                          id=mForm:bidItem_${index}:unit_input    ${code}
  Wait Until Page Contains Element    xpath=//div[@id='mForm:bidItem_${index}:unit_panel']//tr/td[1]   10
  Click Element                       xpath=//div[@id='mForm:bidItem_${index}:unit_panel']//tr/td[1]
  Input text                          id=mForm:bidItem_${index}:amount   ${quantity}
  Click Element                       xpath=//*[@id="mForm:bidItem_${index}:cReg"]/div[3]
  Sleep  1
  Click Element                       xpath=//ul[@id="mForm:bidItem_${index}:cReg_items"]/li[text()="м.Київ"]
  Sleep  1
  Input Text                       xpath=//*[@id="mForm:bidItem_${index}:cTer_input"]  ${item_locality}
  Wait Until Page Contains Element  id=mForm:bidItem_${index}:cTer_panel  10
  Click Element                       xpath=//*[@id="mForm:bidItem_${index}:cTer_panel"]/ul/li[1]
  Sleep  1
  Input text                          id=mForm:bidItem_${index}:zc  ${item_delivery_postal_code}
  Input text                          xpath=//*[@id="mForm:bidItem_${index}:delAdr"]  ${item_delivery_address_street_address}

Додати предмет закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${item}
  ${tender_status}=  get text  id=mForm:status
  Return From Keyword If  '${tender_status}' == 'Очікування пропозицій'
  ${items_count}=  publicbid.Отримати кількість предметів в тендері  ${username}  ${tender_uaid}
  publicbid.Додати предмет  ${item}  ${items_count}

Видалити предмет закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}
  ${tender_status}=  get text  id=mForm:status
  Return From Keyword If  '${tender_status}' == 'Очікування пропозицій'
  Click Element  xpath=//textarea[contains(text(), '${item_id}')]/ancestor::tbody[1]/tr[1]/td[3]/button
  Sleep  5

Отримати кількість предметів в тендері
  [Arguments]  ${username}  ${tender_uaid}
  Capture Page Screenshot
  ${itewms_count}=  get matching xpath count  xpath=//div[@id='mForm:itemsData']/table
  [Return]  ${itewms_count}

Пошук тендера по ідентифікатору
  [Arguments]  ${username}  ${tender_uaid}
  [Documentation]
  ...      ${username} ==  username
  ...      ${tender_uaid} ==  tender_uaid
  Click Element  xpath=//a[./text()="Електронні торги"]
  Wait Until Page Contains Element    id=mForm:search_button   10
  Click Element  xpath=//*[text()='Переглянути тестові електронні торги']
  Wait Until Page Contains Element  xpath=//*[text()='ТЕСТОВИЙ РЕЖИМ']  60
  Click Element  xpath=//*[@id="buttons"]/button[4]
  Wait Until Page Contains Element  id=mForm:search-by-number-input  3
  Input Text   id=mForm:search-by-number-input  ${tender_uaid}
  Press Key  id=mForm:search-by-number-input  \\13
  Sleep  2
  :FOR    ${INDEX}    IN RANGE    1    30
  \  ${find}=  Run Keyword And Return Status  Page Should Contain Element  xpath=//p[contains(text(), '${tender_uaid}')]/ancestor::div[1]/span[2]/a
  \  Exit For Loop If  '${find}' == 'True'
  \  Sleep  10
  \  Clear Element Text  id=mForm:search-by-number-input
  \  Input Text   id=mForm:search-by-number-input  ${tender_uaid}
  \  Press Key  id=mForm:search-by-number-input  \\13
  \  Sleep  5
  Sleep  1
  Click Element    xpath=//p[contains(text(), '${tender_uaid}')]/ancestor::div[1]/span[2]/a
  Wait Until Page Contains Element  id=mForm:nBid  30
  Capture Page Screenshot

Отримати інформацію із тендера
  [Arguments]  @{ARGUMENTS}
  Log Many  @{ARGUMENTS}
  Switch browser   ${ARGUMENTS[0]}
  Log  ${TENDER['TENDER_UAID']}
  Run Keyword And Return  view.Отримати інформацію про ${ARGUMENTS[2]}

Отримати інформацію із предмету
  [Arguments]  @{ARGUMENTS}
  Log Many  @{ARGUMENTS}
  ${result}=  Run Keyword If  ${ARGUMENTS[3]} == 'description'  Get Text  xpath=//[@id="mForm:bidItem_0:subject"]
  [Return]  ${result}

Отримати кількість документів в тендері
  [Arguments]  ${username}  ${tender_uaid}
  Capture Page Screenshot
  ${doc_count}=  get matching xpath count  xpath=//div[@id="mForm:pnlFiles"]/div[3]/div/div/table/tbody/tr
  [Return]  ${doc_count}

Отримати інформацію із документа по індексу
  [Arguments]  ${username}  ${tender_uaid}  ${index}  ${field}
  Capture Page Screenshot
  ${xpath}=  publicbid_service.get_document_field_xpath_by_index  ${index}  ${field}
  ${document_type}=  Get Text  xpath=${xpath}
  ${document_type}=  publicbid_service.get_document_type  ${document_type}
  [Return]  ${document_type}

Внести зміни в тендер
  [Arguments]  ${username}  ${tender_uaid}  ${field}  ${value}
  Switch Browser    ${username}
  publicbid.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Wait Until Page Contains Element   xpath=//*[@id="mForm:status"]   10
  ${field_id}=  publicbid_service.get_field_id  ${field}
  ${field_value}=  publicbid_service.get_field_value  ${field}  ${value}
  Input Text  id=${field_id}  ${field_value}
  Sleep  3
  Click Element              xpath=//*[@id="mForm:bSave"]
  Sleep  3


Задати питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} = question_data

  ${title}=        Get From Dictionary  ${ARGUMENTS[2].data}  title
  ${description}=  Get From Dictionary  ${ARGUMENTS[2].data}  description

  Switch Browser    ${ARGUMENTS[0]}
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
  Switch Browser    ${ARGUMENTS[0]}
  publicbid.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}   ${ARGUMENTS[1]}

Подати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${bid_data}
  [Documentation]
  ...      ${username} ==  username
  ...      ${tender_uaid} ==  tender_uaid
  ...      ${bid_data} ==  bid_data
  ${amount}=  Get From Dictionary   ${bid_data.data.value}  amount
  publicbid.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Click Element  xpath=//*[text()='Подати пропозицію в тестовому режимі']
  Wait Until Page Contains Element  id=mForm:amount  10
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
  ${is_qualified}=  Get From Dictionary  ${bid_data.data}  qualified
  Run Keyword If  ${is_qualified} == False
  ...  Змінити кваліфікацію пропозиції  ${username}  ${tender_uaid}  ${False}
  reload page
  ${qualified_message_does_not_exist}=  run keyword and return status  page should not contain element  xpath=//*[text()='Перевіряється оплата гарантійного внеску']
  Run Keyword If  ${qualified_message_does_not_exist} == False
  ...  Fail  "Неможливо подати пропозицію без кваліфікації"
  Click Element  xpath=//*[text()='Зареєструвати пропозицію']
  Sleep  5
  ${bid_number}=  Get Text  id=mForm:proposal_nompp
  Capture Page Screenshot
  Sleep  60
  reload page
  Capture Page Screenshot
  [Return]  ${bid_number}

Отримати інформацію із пропозиції
  [Arguments]  @{ARGUMENTS}
  Log many  @{ARGUMENTS}
  ${return_value}=  get value  id=mForm:amount
  ${return_value}=  convert to number  ${return_value}
  Capture Page Screenshot
  [Return]  ${return_value}

Скасувати цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}
  Пошук цінової пропозиції  ${username}  ${tender_uaid}
  Capture Page Screenshot
  Click Element  xpath=//*[@id="mForm:proposalCancelBtn"]
  Capture Page Screenshot
  Click Element  xpath=//*[@id="mForm:proposalCancelBtnYes"]
  Sleep  5


Пошук цінової пропозиції
  [Arguments]  ${username}  ${tender_uaid}
  Click Element  xpath=//div[contains(@class, 'cabinet-user-name')]
  Wait Until Page Contains Element  xpath=//a[contains(text(), '${tender_uaid}')]  60
  ${proposal_count}=  Get Matching Xpath Count  xpath=//a[contains(text(), '${tender_uaid}')]/ancestor::div[2]/div[1]/div/span[1]/a
  Run Keyword If  ${proposal_count} > 1
  ...  Click Element  xpath=//a[contains(text(), 'Пропозиція № ${USERS.users['${username}'].bidresponses.resp}')]
  ...  ELSE
  ...  Click Element  xpath=//a[contains(text(), '${tender_uaid}')]/ancestor::div[2]/div[1]/div/span[1]/a
  Wait Until Page Contains Element  id=mForm:amount  30
  Capture Page Screenshot

Відповісти на питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} = 0
  ...      ${ARGUMENTS[3]} = answer_data

  ${answer}=     Get From Dictionary  ${ARGUMENTS[3].data}  answer

  Switch Browser    ${ARGUMENTS[0]}
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
  Switch Browser    ${username}
  publicbid.Пошук тендера по ідентифікатору  ${username}  ${bid_number}
  Capture Page Screenshot
  Sleep  3
  ${url}=  Get Element Attribute  id=mForm:auctionLink@href
  [Return]  ${url}

Отримати посилання на аукціон для учасника
  [Arguments]  ${username}  ${tender_uaid}
  [Documentation]
  ...   ${username} === username
  ...   ${tender_uaid} == tender_uaid
  Switch Browser    ${username}
  publicbid.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Capture Page Screenshot
  Sleep  3
  ${url}=  Get Element Attribute  id=mForm:participationLink@href
  [Return]  ${url}

Змінити цінову пропозицію
  [Arguments]  ${username}  ${tender_uaid}  ${field}  ${new_amount}
  Пошук цінової пропозиції  ${username}  ${tender_uaid}
  ${new_amount}=  convert to string  ${new_amount}
  Input Text  xpath=//*[@id="mForm:amount"]  ${new_amount}
  Click Element  xpath=//*[text()='Зберегти']
  Sleep  5

Завантажити документ в ставку
  [Arguments]  ${username}  ${file_path}  ${bid_number}
  Пошук цінової пропозиції  ${username}  ${bid_number}
  Capture Page Screenshot
  Choose File       xpath=//input[@id="mForm:qFile_input"]    ${file_path}
  Sleep  3
  Capture Page Screenshot
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
  [Arguments]  ${username}  ${tender_uaid}  ${file}  ${doc_id}
  Пошук цінової пропозиції  ${username}  ${tender_uaid}
  Click Element  xpath=//*[@id="mForm:pnlFilesQ""]/div/div/div/table/tbody/tr[1]/td[5]/button[2]
  Sleep  1
  Click Element  xpath=//div[contains(@class, "ui-confirm-diaLog") and @aria-hidden="false"]//span[text()="Так"]
  Sleep  1
  Choose File       xpath=//input[@id="mForm:qFile_input"]    ${file}
  Sleep  3
  Capture Page Screenshot
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
  [Arguments]  ${username}  ${tender_uaid}  ${index}
#  Пошук учасника закупівлі  ${username}  ${tender_uaid}  0
  Capture Page Screenshot
  Пошук учасника закупівлі  ${username}  ${tender_uaid}  0
  ${financial_license_path}  ${file_title}  ${file_content}=  create_fake_doc
  Choose File  id=mForm:contract-signed-upload-input_input  ${financial_license_path}
  Wait Until Page Contains Element    xpath=//*[text()='Картка документу']  10
  Click Element  id=mForm:docCard:dcType_label
  Wait Until Page Contains Element  id=mForm:docCard:dcType_panel  10
  Click Element  xpath=//*[@id="mForm:docCard:dcType_2"]
  Click Element  xpath=//*[@id="mForm:docCard:docCard"]/table/tfoot/tr/td/button[1]
  Sleep  5
  ${current_date}=  Get Current Date
  ${current_date}=  publicbid_service.convert_date_to_string  ${current_date}
  Input text  id=mForm:dc_input  ${current_date}
  Input text  id=mForm:contractNumber  123456
  Sleep  3
  Capture Page Screenshot
  Click Element  id=mForm:bS
  Wait Until Element Is Visible  id=notifyBar  120
  Sleep  3
  Capture Page Screenshot
  Click Element  id=mForm:bS2
  Capture Page Screenshot
  Click Element  id=mForm:cdFinish-yes-btn
  Sleep  3
  Capture Page Screenshot


Підтвердити постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${index}
  Capture Page Screenshot
  Log  ${username}
  Log  ${tender_uaid}
  Log  ${index}
  Пошук учасника закупівлі  ${username}  ${tender_uaid}  ${index}
  Capture Page Screenshot
  Click Element  id=mForm:bW
  Click Element  id=mForm:cdWinner-yes-btn
  Sleep  3
  Click Element  id=mForm:bRS
  Wait Until Element Is Visible  id=notifyBar  120
  Capture Page Screenshot


Отримати інформацію із запитання
  [Arguments]  ${username}  ${tender_uaid}  ${question_id}  ${field}
  Capture Page Screenshot
  Log  ${username}
  Log  ${tender_uaid}
  Log  ${question_id}
  Log  ${field}
  Execute JavaScript  window.scrollTo(0,0)
  ${status}=  Run Keyword And Return Status  Page Should Contain Element  xpath=//span[contains(text(), '${question_id}')]
  Run Keyword If  ${status} == False  Click Element  xpath=//span[./text()='Обговорення']
  Capture Page Screenshot
  ${xpath}=  publicbid_service.get_question_xpath  ${field}  ${question_id}
  ${result}=  get text  xpath=${xpath}
  Log  ${result}
  [Return]  ${result}

Скасувати закупівлю
  [Arguments]  ${username}  ${tender_uaid}  ${cancellation_reason}  ${cancellation_file}  ${cancellation_description}
  publicbid.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
  Click Element  id=mForm:tender-cancel-btn
  Wait Until Page Contains Element  id=mForm:cReason  10
  Click Element  id=mForm:cReason
  Wait Until Page Contains Element  id=mForm:cReason_panel  10
  Sleep  1
  Click Element  xpath=//li[text()='${cancellation_reason}']
  Choose File  id=mForm:docFile_input  ${cancellation_file}
  Wait Until Page Contains Element  xpath=//*[text()="Картка документу"]  10
  Input Text  xpath=//*[@id="mForm:docCard:docCard"]/table/tbody/tr[2]/td[2]/textarea  ${cancellation_description}
  Click Element  xpath=//*[@id="mForm:docCard:docCard"]/table/tfoot/tr/td/button[1]
  Sleep  3
  Click Element  id=mForm:cancellation-active-btn
  Wait Until Page Contains Element  id=infoBar  30
  Sleep  3


Отримати інформацію із документа
  [Arguments]  ${username}  ${tender_uaid}  ${document_id}  ${field}
  Reload Page
  Capture Page Screenshot
  publicbid.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  ${field_xpath}=  publicbid_service.get_document_field_xpath_by_id  ${field}  ${document_id}
  ${return_value}=  Get Text  xpath=${field_xpath}
  ${return_value}=  Convert To String  ${return_value}
  [Return]  ${return_value}

Отримати документ
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}
  ${field_xpath}=  publicbid_service.get_document_field_xpath_by_id  title  ${doc_id}
  ${url}=  Get Element Attribute  xpath=${field_xpath}@href
  ${return_value}=  Get Text  xpath=${field_xpath}
  ${return_value}=  Convert To String  ${return_value}
  publicbid_service.download_file  ${url}  ${return_value}
  [Return]  ${return_value}

Відповісти на запитання
  [Arguments]  ${username}  ${tender_uaid}  ${answer_data}  ${question_id}
  [Documentation]  Можливість відповісти на запитання
  ...      ${username}  ==  username
  ...      ${tender_uaid}  ==  tender_uaid
  ...      ${answer_data}  ==  answer_data
  ...      ${question_id}  ==  question_id
  Log  ${username}
  Log  ${tender_uaid}
  Log  ${answer_data}
  Log  ${question_id}
  Capture Page Screenshot
  ${status}=  Run Keyword And Return Status  Page Should Contain Element  xpath=//span[contains(text(), '${question_id}')]
  Run Keyword If  ${status} == False
  ...  Run Keywords
  ...    Click Element  id=mForm:tender-discussion-btn
  ...    AND  Wait Until Page Contains Element  xpath=//span[contains(text(), '${question_id}')]  10
  ...    AND  Capture Page Screenshot
  Click Element  xpath=//span[contains(text(), '${question_id}')]/ancestor::tr/td[5]/button
  Wait Until Page Contains Element  id=mForm:messQ  10
  Input Text  id=mForm:messQ  ${answer_data.data.answer}
  Click Element  id=mForm:btnR
  Capture Page Screenshot

Скасування рішення кваліфікаційної комісії
  [Arguments]  ${username}  ${tender_uaid}  ${index}
  Capture Page Screenshot
  Log  ${username}
  Log  ${tender_uaid}
  Log  ${index}
  Пошук учасника закупівлі  ${username}  ${tender_uaid}  ${index}
  Click Element  id=mForm:bDc
  Wait Until Page Contains Element  id=primefacesmessagedlg  60


Завантажити документ рішення кваліфікаційної комісії
  [Arguments]  ${username}  ${file}  ${tender_uaid}  ${index}
  Capture Page Screenshot
  Log  ${username}
  Log  ${file}
  Log  ${tender_uaid}
  Log  ${index}
  Sleep  80
  Пошук учасника закупівлі  ${username}  ${tender_uaid}  ${index}
  Capture Page Screenshot
  Choose File  id=mForm:tdFile_input  ${file}
  Wait Until Page Contains Element  id=mForm:docCard:dcType_label  10
  Click Element  id=mForm:docCard:dcType_label
  Wait Until Page Contains Element  id=mForm:docCard:dcType_1  10
  Click Element  id=mForm:docCard:dcType_1
  Click Element  id=mForm:docCard:dc-save-btn
  Sleep  2
  Click Element  id=mForm:save-btn
  Capture Page Screenshot
  Sleep  15
  Capture Page Screenshot


Отримати кількість документів в ставці
  [Arguments]  ${username}  ${tender_uaid}  ${index}
  Log  ${username}
  Log  ${tender_uaid}
  Log  ${index}
  Capture Page Screenshot
  Sleep  80
  Пошук учасника закупівлі  ${username}  ${tender_uaid}  ${index}
  ${count_of_documents}=  Get Matching Xpath Count  xpath=//tbody[@id='mForm:proposalDocuments:dg-data-table_data']/tr
  [Return]  ${count_of_documents}


Пошук учасника закупівлі
  [Arguments]  ${username}  ${tender_uaid}  ${index}
  Capture Page Screenshot
  Log  ${username}
  Log  ${tender_uaid}
  Log  ${index}
  publicbid.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  id=mForm:auction-results-btn
  Wait Until Page Contains Element  id=mForm:mForm:auctions-bidders-btn  10
  Click Element  id=mForm:mForm:auctions-bidders-btn
  Sleep  5
  ${award_count}=  Get Matching Xpath Count  xpath=//*[@id="mForm:data_data"]/tr
  Log  ${index}
  Log  ${award_count}
  ${index}=  publicbid_service.get_award_index  ${index}  ${award_count}
  Log  ${index}
  ${status}=  Run Keyword And Return Status  Page Should Contain Element  id=mForm:data:${index}:rate-btn
  ${button_id}=  Run Keyword If  ${status} == True
  ...  Set Variable  mForm:data:${index}:rate-btn
  ...  ELSE  Set Variable  mForm:data:${index}:rate-contract-sign-btn
  Click Element  id=${button_id}
  Sleep  15
  ${auction_protocol_loaded}=  run keyword and return status  page should contain element  xpath=//span[text()='Протокол аукціону']
  :FOR    ${INDEX}    IN RANGE    1    25
  \  Capture Page Screenshot
  \  Exit For Loop If  ${auction_protocol_loaded} == True
  \  Sleep  3
  \  ${auction_protocol_loaded}=  run keyword and return status  page should contain element  xpath=//span[text()='Протокол аукціону']
  \  Run Keyword If  ${auction_protocol_loaded} == False  Sleep  15
  \  Run Keyword If  ${auction_protocol_loaded} == False  Reload Page
  \  Capture Page Screenshot
  Capture Page Screenshot


Отримати дані із документу пропозиції
  [Arguments]  ${username}  ${tender_uaid}  ${bid_index}  ${document_index}  ${field}
  Capture Page Screenshot
  Log  ${username}
  Log  ${tender_uaid}
  Log  ${bid_index}
  Log  ${document_index}
  Log  ${field}
  ${result}=  Run Keyword If  '${field}' == 'documentType'
  ...  Get Text  id=mForm:proposalDocuments:dg-data-table:${document_index}:dg-type-name-txt
  ${result}=  get_proposal_document_type  ${result}
  [Return]  ${result}


Дискваліфікувати постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${index}  ${description}
  Capture Page Screenshot
  Log  ${username}
  Log  ${tender_uaid}
  Log  ${index}
  Log  ${description}
  Capture Page Screenshot
  Click Element  id=mForm:bD
  Wait Until Page COntains Element  id=mForm:cdDisqualif-yes-btn  10
  Click Element  id=mForm:cdDisqualif-yes-btn
  Sleep  3
  ${status}=  Run Keyword And Return Status  Page Should Contain Element  id=primefacesmessagedlg
  Run Keyword If  ${status} == True  Run Keywords
  ...  Click Element  xpath=//*[@id="primefacesmessagedlg"]/div[1]/a[1]/span
  ...  AND
  ...  Sleep  1
  Select Checkbox  xpath=//*[@id="mForm:cdRateRejectPanel"]/div[1]/table/tbody/tr[1]/td[1]/input[1]
  Sleep  2
  Click Element  id=mForm:bRS
  Wait Until Element Is Visible  id=notifyBar  120
  Sleep  2
  Capture Page Screenshot


Завантажити угоду до тендера
  [Arguments]  ${username}  ${tender_uaid}  ${index}  ${file_path}
  Capture Page Screenshot
  Log  ${username}
  Log  ${tender_uaid}
  Log  ${index}
  Log  ${file_path}
  Пошук учасника закупівлі  ${username}  ${tender_uaid}  0
  Choose File  id=mForm:contract-project-upload-input_input  ${file_path}
  Wait Until Page Contains Element    xpath=//*[text()='Картка документу']  10
  Click Element  id=mForm:docCard:dcType_label
  Wait Until Page Contains Element  id=mForm:docCard:dcType_panel  10
  Click Element  xpath=//*[@id="mForm:docCard:dcType_1"]
  Click Element  xpath=//*[@id="mForm:docCard:docCard"]/table/tfoot/tr/td/button[1]
  Sleep  2
  Execute JavaScript  window.scrollTo(0,0)
  Click Element  id=mForm:bS
  Wait Until Element Is Visible  id=notifyBar  120

Задати запитання на тендер
  [Arguments]  ${username}  ${tender_uaid}  ${question_data}
  Capture Page Screenshot
  publicbid.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  id=mForm:tender-discussion-btn
  Wait Until Page Contains Element  id=mForm:messP
  Input Text  id=mForm:messT  ${question_data.data.title}
  Input Text  id=mForm:messQ  ${question_data.data.description}
  Click Element  id=mForm:btnQ
  Sleep  5
  Capture Page Screenshot

Задати запитання на предмет
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${question_data}
  Capture Page Screenshot
  publicbid.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Click Element  id=mForm:tender-discussion-btn
  Wait Until Page Contains Element  id=mForm:messP
  Click Element  id=mForm:questTo_label
  Click Element  id=mForm:questTo_1
  Input Text  id=mForm:messT  ${question_data.data.title}
  Input Text  id=mForm:messQ  ${question_data.data.description}
  Click Element  id=mForm:btnQ
  Sleep  5
  Capture Page Screenshot

Завантажити фінансову ліцензію
  [Arguments]  ${username}  ${tender_uaid}  ${license_path}
  Capture Page Screenshot


Завантажити протокол аукціону
  [Arguments]  ${username}  ${tender_uaid}  ${auction_protocol_path}  ${bid_index}
  Capture Page Screenshot
  Пошук цінової пропозиції  ${username}  ${tender_uaid}
  Click Element  xpath=//*[text()='Додати документи до пропозиції']
  Sleep  2
  Choose File  id=mForm:qFile_input  ${auction_protocol_path}
  Wait Until Page Contains Element  id=mForm:docCard:dcType_label  10
  Click Element  id=mForm:docCard:dcType_label
  Click Element  id=mForm:docCard:dcType_1
  Click Element  id=mForm:docCard:dc-save-btn
  Sleep  3
  Click Element  id=mForm:proposalSaveBtn
  Wait Until Element Is Visible  id=notifyBar  120
  Sleep  3

Змінити кваліфікацію пропозиції
  [Arguments]  ${username}  ${tender_uaid}  ${change}
  Open Browser  ${USERS.users['${username}'].homepage}  ${USERS.users['${username}'].browser}  alias=ADMIN
  Set Window Size   @{USERS.users['${username}'].size}
  Set Window Position   @{USERS.users['${username}'].position}

  Run Keyword And Ignore Error   Wait Until Page Contains Element    xpath=//*[text()='Вхід']   10
  Click Element                      xpath=//*[text()='Вхід']
  Run Keyword And Ignore Error   Wait Until Page Contains Element   id=mForm:email   10
  Input text   id=mForm:email      test_eauction@yopmail.com
  Input text   id=mForm:pwd      P@ssw0rd
  Click Button   id=mForm:login
  Sleep  3
  ${present}=  Run Keyword And Return Status    Element Should Be Visible   id=mForm:existNotResolvedQuestionsOrAppealsDiaLog
  Run Keyword If  ${present}  Click Element  xpath=//*[@id='mForm:existNotResolvedQuestionsOrAppealsDiaLog']/div[3]/a
  Sleep  4
  Click Element  id=menu-admin-Logged-in-lnk
  Wait Until Page Contains Element  xpath=//a[contains(text(), '${tender_uaid}')]/ancestor::div[3]/div[3]/p[2]/button
  Click Element  xpath=//a[contains(text(), '${tender_uaid}')]/ancestor::div[3]/div[3]/p[2]/button
  Sleep  5
  Click Element  xpath=//a[contains(text(), '${tender_uaid}')]/ancestor::div[3]/div[4]/div/p[2]/button
  Sleep  5
  Switch Browser  ${username}

Додати публічний паспорт активу
  [Arguments]  ${username}  ${tender_uaid}  ${doc}
  Capture Page Screenshot
  Додати посилання до тендеру  ${doc}  x_dgfPublicAssetCertificate  Посилання на Публічний Паспорт Активу
  Capture Page Screenshot
  Execute JavaScript  window.scrollTo(0,0)
  Click Element  xpath=//*[@id="mForm:bSave"]
  Wait Until Element Is Visible  xpath=//*[text()='Збережено!']  120
  Capture Page Screenshot
  Sleep  5


Завантажити документ в тендер з типом
  [Arguments]  ${username}  ${tender_uaid}  ${doc}  ${doc_type}
  Завантажити документ до тендеру  ${doc}  ${doc_type}
  Capture Page Screenshot
  Execute JavaScript  window.scrollTo(0,0)
  Capture Page Screenshot
  Click Element  xpath=//*[@id="mForm:bSave"]
  Wait Until Element Is Visible  xpath=//*[text()='Збережено!']  120
  Capture Page Screenshot
  Sleep  5

Додати офлайн документ
  [Arguments]  ${username}  ${tender_uaid}  ${doc}
  Capture Page Screenshot
  Click Element  id=mForm:add-asset-familiarization-btn
  Sleep  3
  Click Element  id=mForm:docCard:dcType_label
  Click Element  id=mForm:docCard:dcType_1
  Input Text  id=mForm:docCard:fileName  Порядок ознайомлення з активом у кімнаті даних
  Input Text  id=mForm:docCard:accessDetails  ${doc}
  Click Element  id=mForm:docCard:dc-save-btn
  Sleep  3
  Execute JavaScript  window.scrollTo(0,0)
  Capture Page Screenshot
  Click Element  xpath=//*[@id="mForm:bSave"]
  Wait Until Element Is Visible  xpath=//*[text()='Збережено!']  120
  Capture Page Screenshot
  Sleep  5

Додати посилання до тендеру
  [Arguments]  ${link}  ${doc_type}  ${name}
  Click Element  xpath=//span[text()='Додати посилання']
  Sleep  3
  Capture Page Screenshot
  Wait Until Page Contains Element  id=mForm:docCard:extUrl  10
  ${doc_type_xpath}=  publicbid_service.get_document_link_type_xpath  ${doc_type}
  Click Element  id=mForm:docCard:dcType_label
  Wait Until Page Contains Element  xpath=${doc_type_xpath}  10
  Click Element  xpath=${doc_type_xpath}
  Input Text  id=mForm:docCard:fileName  ${name}
  Input Text  id=mForm:docCard:extUrl  ${link}
  Capture Page Screenshot
  Click Element  id=mForm:docCard:dc-save-btn
  Sleep  5
  Capture Page Screenshot
