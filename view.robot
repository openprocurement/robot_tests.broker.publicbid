*** Settings ***
Library  Selenium2Library
Library  String
Library  DateTime
Library  publicbid_json_util.py
Library  publicbid_service.py
Resource  publicbid.robot

*** Keywords ***
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
  ${return_value}=  Get Value  xpath=//*[@id="mForm:budget"]
  Log  ${return_value}
  ${return_value}=  publicbid_service.string_replace  ${return_value}  ${space}  ${empty}
  ${return_value}=  publicbid_service.string_replace  ${return_value}  ,  .
  Log  ${return_value}
  ${return_value}=  Convert To Number   ${return_value}
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

Отримати інформацію про items[${index}].description
  ${return_value}=  Get Text           xpath=//*[@id="mForm:bidItem_${index}:subject"]
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

Отримати інформацію про items[${index}].classification.scheme
  ${return_value}=  Get Text           xpath=//*[@id="mForm:bidItem_${index}:item${index}"]/tbody/tr[2]/td[1]/label
  ${return_value}=  Get Substring  ${return_value}  4  7
  ${return_value}=  Convert To String  ${return_value}
  [Return]  ${return_value}

Отримати інформацію про items[${index}].classification.id
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_${index}:cCpv_input"]
  ${return_value}=  Get Substring  ${return_value}  0  10
  [Return]  ${return_value}

Отримати інформацію про items[${index}].classification.description
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_${index}:cCpv_input"]
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

Отримати інформацію про items[${index}].unit.name
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_${index}:unit_input"]
  ${return_value}=  Get Substring  ${return_value}  4
  ${return_value}=  Convert To String  ${return_value}
  [Return]  ${return_value}

Отримати інформацію про items[${index}].unit.code
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_${index}:unit_input"]
  ${return_value}=  Get Substring  ${return_value}  0  3
  ${return_value}=  Convert To String  ${return_value}
  [Return]  ${return_value}

Отримати інформацію про items[${index}].quantity
  ${return_value}=  Get Value           xpath=//*[@id="mForm:bidItem_${index}:amount"]
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

Отримати інформацію про questions[${index}].title
  Click Element  xpath=//*[text()="Обговорення"]
  Sleep  5
  Capture Page Screenshot
  ${return_value}=  Get Text  id=mForm:data:${index}:title
  [Return]  ${return_value}

Отримати інформацію про questions[${index}].description
  Capture Page Screenshot
  ${xpath}=  publicbid_service.get_question_answer_by_type_xpath  question  ${index}
  ${return_value}=  Get Text  xpath=${xpath}
  [Return]  ${return_value}

Отримати інформацію про questions[${index}].date
  ${return_value}=  Get Text  xpath=//*[@id="mForm:data_data"]/tr/td[4]
  ${return_value}=  publicbid_service.parse_date  ${return_value}
  [Return]  ${return_value}

Отримати інформацію про questions[${index}].answer
  capture page screenshot
  Click Element  xpath=//*[text()="Обговорення"]
  Sleep  5
  capture page screenshot
  ${xpath}=  get_question_answer_by_type_xpath  answer  ${index}
  ${return_value}=  Get Text  xpath=${xpath}
  [Return]  ${return_value}

Отримати інформацію про auctionPeriod.endDate
  ${return_value}=  Wait Until Keyword Succeeds  20x  5 sec  Отримати текст  mForm:auctionEndDate
  ${return_value}=  publicbid_service.parse date  ${return_value}
  [Return]  ${return_value}

Отримати текст
  [Arguments]  ${id}
  reload page
  capture page screenshot
  ${return_value}=  Get Text  id=${id}
  [Return]  ${return_value}

Отримати інформацію про cancellations[0].status
  Capture Page Screenshot
  Reload Page
  Click Element  id=mForm:cancellation-reason-lnk
  Wait Until Page Contains Element  id=mForm:cStatus  10
  ${return_value}=  Get Text  id=mForm:cStatus
  ${return_value}=  get_cancellation_code  ${return_value}
  ${return_value}=  Convert To String  ${return_value}
  [Return]  ${return_value}

Отримати інформацію про cancellations[0].reason
  Capture Page Screenshot
  Click Element  id=mForm:cancellation-reason-lnk
  wait until page contains element  id=mForm:cReason-txt  10
  ${return_value}=  Get Text  id=mForm:cReason-txt
  [Return]  ${return_value}

Отримати інформацію про eligibilityCriteria
  Capture Page Screenshot

Отримати інформацію про dgfDecisionDate
  ${return_value}=  Get Value  id=mForm:dgfDecisionDate_input
  ${return_value}=  publicbid_service.convert_date  ${return_value}  %d.%m.%Y  %Y-%m-%d
  [Return]  ${return_value}

Отримати інформацію про dgfDecisionID
  ${return_value}=  Get Text  id=mForm:dgfDecisionId
  [Return]  ${return_value}

Отримати інформацію про tenderAttempts
  ${return_value}=  Get Text  id=mForm:tenderAttempts_label
  [Return]  ${return_value}

Отримати інформацію про procurementMethodType
  ${return_value}=  Get Text  id=mForm:procurementMethodName
  ${return_value}=  publicbid_service.get_tender_type  ${return_value}
  [Return]  ${return_value}

Отримати інформацію про awards[0].status
  publicbid.Потрапити на сторінку результатів аукціону
  ${return_value}=  Get Text    xpath=//td[text()='1']/ancestor::tr[1]/td[5]
  ${return_value}=  publicbid_service.get_awards_status  ${return_value}
  [Return]  ${return_value}

Отримати інформацію про awards[1].status
  Run Keyword If  "${TEST NAME}" != "Відображення статусу 'очікується протокол' для другого кандидата"  publicbid.Потрапити на сторінку результатів аукціону
  ${return_value}=  Get Text    xpath=//td[text()='2']/ancestor::tr[1]/td[5]
  ${return_value}=  publicbid_service.get_awards_status  ${return_value}
  [Return]  ${return_value}

Отримати інформацію про awards[-1].status
  Run Keyword If  "${TEST NAME}" != "Відображення статусу 'очікується протокол' для другого кандидата"  publicbid.Потрапити на сторінку результатів аукціону
  ${return_value}=  Get Text    xpath=//td[text()='2']/ancestor::tr[1]/td[5]
  ${return_value}=  publicbid_service.get_awards_status  ${return_value}
  [Return]  ${return_value}







