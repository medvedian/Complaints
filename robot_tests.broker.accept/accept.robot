*** Settings ***
Library  Selenium2Library
Library  accept_service.py
Library   Collections
Library   DateTime
Library   String


*** Variables ***
${Кнопка "Вхід"}  xpath=  /html/body/app-shell/md-content/app-content/div/div[2]/div[2]/div/div/md-content/div/div[2]/div[1]/div[2]/div/login-panel/div/div/button
${Кнопка "Мої закупівлі"}  xpath=  /html/body/app-shell/md-toolbar[1]/app-header/div[1]/div[4]/div[1]/sub-menu/div/div[1]/div/div[1]/a
${Кнопка "Створити"}  xpath=  .//a[@ui-sref='root.dashboard.tenderDraft({id:0})']
${Поле "Процедура закупівлі"}  xpath=  //div[@class='TenderEditPanel TenderDraftTabsContainer']//*[@id="procurementMethodType"]
${Поле "Узагальнена назва закупівлі"}  id=  title
${Поле "Узагальнена назва лоту"}  id=  lotTitle-0
${Поле "Конкретна назва предмета закупівлі"}  id=  itemDescription--
${Поле "Процедура закупівлі" варіант "Переговорна процедура"}  xpath=  //div [@class='md-select-menu-container md-active md-clickable']//md-select-menu [@class = '_md']//md-content [@class = '_md']//md-option[5]
${Вкладка "Лоти закупівлі"}  xpath=  /html/body/app-shell/md-content/app-content/div/div[2]/div[2]/div/div/div/md-content/div/form/div/div/md-content/ng-transclude/md-tabs/md-tabs-wrapper/md-tabs-canvas/md-pagination-wrapper/md-tab-item[2]
${Поле "Підстава для використання"}  id=  cause
${Поле "Підстава для використання" варіант "Потреба здійснити додаткову закупівлю"}  xpath=  //div [@class='md-select-menu-container md-active md-clickable']//md-select-menu [@class='_md']//md-content[@class='_md']//md-option[4]
${Перший елемент класифікатора ДК 021:2015}  id=  03000000-1_0_anchor
#${Поле "Одиниці виміру" варіант "ампер"}  xpath=  //*[@id="unit-unit--"]/option[2]
${Кнопка "Опублікувати"}  id=  tender-publish
${Кнопка "Так" у попап вікні}  xpath=  /html/body/div[1]/div/div/div[3]/button[1]
${Посилання на тендер}  id=  tenderUID
${Кнопка "Зберегти учасника переговорів"}  id=  tender-create-award
${Поле "Ціна пропозиції"}  id=  award-value-amount
${Поле "Тип документа" (Кваліфікація учасників)}  id=  type-award-document
${Поле "Пошук" у класифікаторі}  id=  search-input-cpv-0-0




*** Keywords ***
Підготувати клієнт для користувача
  [Arguments]     @{ARGUMENTS}
  [Documentation]  Відкрити брaвзер, створити обєкт api wrapper, тощо
  Open Browser  ${USERS.users['${ARGUMENTS[0]}'].homepage}  ${USERS.users['${ARGUMENTS[0]}'].browser}  alias=${ARGUMENTS[0]}
  maximize browser window
  Login   ${ARGUMENTS[0]}

Login
  [Arguments]  @{ARGUMENTS}
  wait until element is visible  ${Кнопка "Вхід"}
  Click Button                   ${Кнопка "Вхід"}
  wait until element is visible  id=username
  Input text                     id=username          ${USERS.users['${ARGUMENTS[0]}'].login}
  Input text                     id=password          ${USERS.users['${ARGUMENTS[0]}'].password}
  Click Button                   id=loginButton

Підготувати дані для оголошення тендера
  [Arguments]  ${username}  ${tender_data}  ${items}
#    ${tender_data1}       adapt_data         ${tender_data}
#    log to console  *
#    log to console  ${tender_data}
#    log to console  *
    [return]    ${tender_data}

Створити тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data
    ${title}=                             Get From Dictionary             ${ARGUMENTS[1].data}                        title
    ${description}=                       Get From Dictionary             ${ARGUMENTS[1].data}                        description
    ${vat}=                               get from dictionary             ${ARGUMENTS[1].data.value}                  valueAddedTaxIncluded
    ${currency}=                          Get From Dictionary             ${ARGUMENTS[1].data.value}                  currency

    ${lots}=                              Get From Dictionary             ${ARGUMENTS[1].data}                        lots
    ${lot_description}=                   Get From Dictionary             ${lots[0]}                                  description
    ${lot_title}=                         Get From Dictionary             ${lots[0]}                                  title
    ${lot_amount_str}=                    convert to string               ${ARGUMENTS[1].data.lots[0].value.amount}
    ${lot_minimal_step_amount}=           get from dictionary             ${lots[0].minimalStep}                      amount
    ${lot_minimal_step_amount_str}=       convert to string               ${lot_minimal_step_amount}

    ${items}=                             Get From Dictionary             ${ARGUMENTS[1].data}                        items
    ${item_description}=                  Get From Dictionary             ${items[0]}                                 description
    # Код CPV
    ${item_scheme}=                       Get From Dictionary             ${items[0].classification}                  scheme
    ${item_id}=                           Get From Dictionary             ${items[0].classification}                  id
    ${item_descr}=                        Get From Dictionary             ${items[0].classification}                  description

    #Код ДК
    run keyword and ignore error  Отримуємо код ДК  ${ARGUMENTS[1]}

    ${item_quantity}=                     Get From Dictionary             ${items[0]}                                 quantity
    ${item_unit}=                         Get From Dictionary             ${items[0].unit}                            name
    #адреса поставки
    ${item_streetAddress}=                Get From Dictionary             ${items[0].deliveryAddress}                 streetAddress
    ${item_locality}=                     Get From Dictionary             ${items[0].deliveryAddress}                 locality
    ${item_region}=                       Get From Dictionary             ${items[0].deliveryAddress}                 region
    ${item_postalCode}=                   Get From Dictionary             ${items[0].deliveryAddress}                 postalCode
    ${item_countryName}=                  Get From Dictionary             ${items[0].deliveryAddress}                 countryName

    #період уточнень
    ${enquiryPeriod_startDate}=           Get From Dictionary             ${ARGUMENTS[1].data.enquiryPeriod}          startDate
    ${enquiryPeriod_endDate}=             Get From Dictionary             ${ARGUMENTS[1].data.enquiryPeriod}          endDate

    #період подачі пропозицій
    ${tenderPeriod_startDate}=            Get From Dictionary             ${ARGUMENTS[1].data.tenderPeriod}           startDate
    ${tenderPeriod_endDate}=              Get From Dictionary             ${ARGUMENTS[1].data.tenderPeriod}           endDate

    #період доставки
    ${delivery_startDate}=                Get From Dictionary             ${items[0].deliveryDate}                    startDate
    ${delivery_endDate}=                  Get From Dictionary             ${items[0].deliveryDate}                    endDate

    #конвертація дат та часу
    ${enquiryPeriod_startDate_str}=       convert_datetime_to_new         ${enquiryPeriod_startDate}
	${enquiryPeriod_startDate_time}=      convert_datetime_to_new_time    ${enquiryPeriod_startDate}
    ${enquiryPeriod_endDate_str}=         convert_datetime_to_new         ${enquiryPeriod_endDate}
	${enquiryPeriod_endDate_time}=        convert_datetime_to_new_time    ${enquiryPeriod_endDate}

    ${tenderPeriod_startDate_str}=        convert_datetime_to_new         ${tenderPeriod_startDate}
	${tenderPeriod_startDate_time}=       convert_datetime_to_new_time    ${tenderPeriod_startDate}
    ${tenderPeriod_endDate_str}=          convert_datetime_to_new         ${tenderPeriod_endDate}
	${tenderPeriod_endDate_time}=         convert_datetime_to_new_time    ${tenderPeriod_endDate}

    ${delivery_StartDate_str}=            convert_datetime_to_new         ${delivery_startDate}
	${delivery_StartDate_time}=           convert_datetime_to_new_time    ${delivery_startDate}
    ${delivery_endDate_str}=              convert_datetime_to_new         ${delivery_endDate}
	${delivery_endDate_time}=             convert_datetime_to_new_time    ${delivery_endDate}

#    ${features}=                          Get From Dictionary             ${ARGUMENTS[1].data}                        features
#    #Нецінові крітерії лоту
#    ${lot_features_title}=                Get From Dictionary             ${features[0]}                              title
#    ${lot_features_description} =         Get From Dictionary             ${features[0]}                              description
#    ${lot_features_of}=                   Get From Dictionary             ${features[0]}                              featureOf
#    ${lot_non_price_1_value}=             convert to number               ${features[0].enum[0].value}
#    ${lot_non_price_1_value}=             percents                        ${lot_non_price_1_value}
#    ${lot_non_price_1_value}=             convert to string               ${lot_non_price_1_value}
#    ${lot_non_price_1_title}=             Get From Dictionary             ${features[0].enum[0]}                      title
#    ${lot_non_price_2_value}=             convert to number               ${features[0].enum[1].value}
#    ${lot_non_price_2_value}=             percents                        ${lot_non_price_2_value}
#    ${lot_non_price_2_value}=             convert to string               ${lot_non_price_2_value}
#    ${lot_non_price_2_title}=             Get From Dictionary             ${features[0].enum[1]}                      title
#    ${lot_non_price_3_value}=             convert to number               ${features[0].enum[2].value}
#    ${lot_non_price_3_value}=             percents                        ${lot_non_price_3_value}
#    ${lot_non_price_3_value}=             convert to string               ${lot_non_price_3_value}
#    ${lot_non_price_3_title}=             Get From Dictionary             ${features[0].enum[2]}                      title
#    #Нецінові крітерії тендеру
#    ${tender_features_title}=             Get From Dictionary             ${features[1]}                              title
#    ${tender_features_description} =      Get From Dictionary             ${features[1]}                              description
#    ${tender_features_of}=                Get From Dictionary             ${features[1]}                              featureOf
#    ${tender_non_price_1_value}=          convert to number               ${features[1].enum[0].value}
#    ${tender_non_price_1_value}=          percents                        ${tender_non_price_1_value}
#    ${tender_non_price_1_value}=          convert to string               ${tender_non_price_1_value}
#    ${tender_non_price_1_title}=          Get From Dictionary             ${features[1].enum[0]}                      title
#    ${tender_non_price_2_value}=          convert to number               ${features[1].enum[1].value}
#    ${tender_non_price_2_value}=          percents                        ${tender_non_price_2_value}
#    ${tender_non_price_2_value}=          convert to string               ${tender_non_price_2_value}
#    ${tender_non_price_2_title}=          Get From Dictionary             ${features[1].enum[1]}                      title
#    ${tender_non_price_3_value}=          convert to number               ${features[1].enum[2].value}
#    ${tender_non_price_3_value}=          percents                        ${tender_non_price_3_value}
#    ${tender_non_price_3_value}=          convert to string               ${tender_non_price_3_value}
#    ${tender_non_price_3_title}=          Get From Dictionary             ${features[1].enum[2]}                      title
#    #Нецінові крітерії айтему
#    ${item_features_title}=               Get From Dictionary             ${features[2]}                              title
#    ${item_features_description} =        Get From Dictionary             ${features[2]}                              description
#    ${item_features_of}=                  Get From Dictionary             ${features[2]}                              featureOf
#    ${item_non_price_1_value}=            convert to number               ${features[2].enum[0].value}
#    ${item_non_price_1_value}=            percents                        ${item_non_price_1_value}
#    ${item_non_price_1_value}             convert to string               ${item_non_price_1_value}
#    ${item_non_price_1_title}=            Get From Dictionary             ${features[2].enum[0]}                      title
#    ${item_non_price_2_value}=            convert to number               ${features[2].enum[1].value}
#    ${item_non_price_2_value}=            percents                        ${item_non_price_2_value}
#    ${item_non_price_2_value}=            convert to string               ${item_non_price_2_value}
#    ${item_non_price_2_title}=            Get From Dictionary             ${features[2].enum[1]}                      title
#    ${item_non_price_3_value}=            convert to number               ${features[2].enum[2].value}
#    ${item_non_price_3_value}=            percents                        ${item_non_price_3_value}
#    ${item_non_price_3_value}=            convert to string               ${item_non_price_3_value}=
#    ${item_non_price_3_title}=            Get From Dictionary             ${features[2].enum[2]}                      title
    #Контактна особа
	${contact_point_name}=                Get From Dictionary             ${ARGUMENTS[1].data.procuringEntity.contactPoint}    name
	${contact_point_phone}=               Get From Dictionary             ${ARGUMENTS[1].data.procuringEntity.contactPoint}    telephone
	${contact_point_fax}=                 Get From Dictionary             ${ARGUMENTS[1].data.procuringEntity.contactPoint}    faxNumber
	${contact_point_email}=               Get From Dictionary             ${ARGUMENTS[1].data.procuringEntity.contactPoint}    email

    ${acceleration_mode}=                 Get From Dictionary             ${ARGUMENTS[1].data}                                 procurementMethodDetails

   #клікаєм на "Мій кабінет"
    click element  xpath=(.//span[@class='ng-binding ng-scope'])[3]
    sleep  2
    wait until element is visible  ${Кнопка "Мої закупівлі"}  30
    click element  ${Кнопка "Мої закупівлі"}
    sleep  2
    wait until element is visible  ${Кнопка "Створити"}  30
    click element  ${Кнопка "Створити"}
    sleep  1
    wait until element is visible  ${Поле "Узагальнена назва закупівлі"}  30
    input text  ${Поле "Узагальнена назва закупівлі"}  ${title}
    run keyword if       '${vat}'     click element      id=tender-value-vat
    sleep  1
    input text  id=description  ${description}
    #Заповнюємо дати
    input text  xpath=(.//input[@class='md-datepicker-input'])[1]                       ${enquiryPeriod_startDate_str}
    sleep  2
    input text  xpath=(//*[@id="timeInput"])[1]                                         ${enquiryPeriod_startDate_time}
    sleep  2
    input text  xpath=(.//input[@class='md-datepicker-input'])[2]                       ${enquiryPeriod_endDate_str}
    sleep  2
    input text  xpath=(//*[@id="timeInput"])[2]                                         ${enquiryPeriod_endDate_time}
    sleep  2
    input text  xpath=(.//input[@class='md-datepicker-input'])[3]                       ${tenderPeriod_startDate_str}
    sleep  2
    input text  xpath=(//*[@id="timeInput"])[3]                                         ${tenderPeriod_startDate_time}
    sleep  2
    input text  xpath=(.//input[@class='md-datepicker-input'])[4]                       ${tenderPeriod_endDate_str}
    sleep  2
    input text  xpath=(//*[@id="timeInput"])[4]                                         ${tenderPeriod_endDate_time}
    sleep  2

    #Переходимо на вкладку "Лоти закупівлі"
#    click element  ${Вкладка "Лоти закупівлі"}
    execute javascript  angular.element("md-tab-item")[1].click()
    sleep  2
    wait until element is visible  ${Поле "Узагальнена назва лоту"}  30
    input text      ${Поле "Узагальнена назва лоту"}                                    ${lot_title}
    #заповнюємо поле "Очікувана вартість закупівлі"
    input text      amount-lot-value.0                                                  ${lot_amount_str}
    sleep  1
    #Заповнюємо поле "Примітки"
    input text      lotDescription-0                                                    ${lot_description}
    #Заповнюємо поле "Мінімальний крок пониження ціни"
    input text      amount-lot-minimalStep.0                                            ${lot_minimal_step_amount_str}

    #переходимо на вкладку "Специфікації закупівлі"
    Execute Javascript  $($("app-tender-lot")).find("md-tab-item")[1].click()
    wait until element is visible  ${Поле "Конкретна назва предмета закупівлі"}  30
    input text      ${Поле "Конкретна назва предмета закупівлі"}                        ${item_description}
    input text      id=itemQuantity--                                                   ${item_quantity}
    #Заповнюємо поле "Код ДК 021-2015 "
    Execute Javascript    $($('[id=cpv]')[0]).scope().value.classification = {id: "${item_id}", description: "${item_description}", scheme: "${item_scheme}"};
    sleep  2
    #Заповнюємо додаткові коди
    run keyword and ignore error  Заповнюємо додаткові коди
    sleep  2
    #Заповнюємо поле "Одиниці виміру"
    Select From List  id=unit-unit--  ${item_unit}
    #Заповнюємо датапікери
    input text      xpath=(*//input[@class='md-datepicker-input'])[5]                   ${delivery_StartDate_str}
    sleep  2
    input text      xpath=(//*[@id="timeInput"])[5]                                     ${delivery_StartDate_time}
    sleep  2
    input text      xpath=(.//input[@class='md-datepicker-input'])[6]                   ${delivery_endDate_str}
    sleep  2
    input text      xpath=(//*[@id="timeInput"])[6]                                     ${delivery_endDate_time}
    sleep  2
    #Заповнюємо адресу доставки
    select from list  id=countryName.value.deliveryAddress--                            ${item_countryName}
    input text        id=streetAddress.value.deliveryAddress--                          ${item_streetAddress}
    input text        id=locality.value.deliveryAddress--                               ${item_locality}
    input text        id=region.value.deliveryAddress--                                 ${item_region}
    input text        id=postalCode.value.deliveryAddress--                             ${item_postalCode}
    sleep  2

#    #Переходимо на вкладку "Інші крітерії оцінки"
#    Execute Javascript          angular.element("md-tab-item")[2].click()
#    sleep  2
#    #заповнюємо нецінові крітерії лоту
#    click element               featureAddAction
#    sleep  1
#    input text                  xpath=(//*[@id="feature.title."])[1]                    ${lot_features_title}
#    input text                  xpath=(//*[@id="feature.description."])[1]              ${lot_features_description}
#    select from list by value   xpath=(//*[@id="feature.featureOf."])[1]                ${lot_features_of}
#    sleep  2
#    select from list by label   xpath=//*[@id="feature.relatedItem."][1]                ${lot_title}
#    sleep  2
#    click element               xpath=(//*[@id="enumAddAction"])[1]
#    sleep  1
#    input text                  enum.title.0.0                                          ${lot_non_price_1_title}
#    input text                  enum.value.0.0                                          ${lot_non_price_1_value}
#    click element               xpath=(//*[@id="enumAddAction"])[1]
#    sleep  1
#    input text                  enum.title.0.1                                          ${lot_non_price_2_title}
#    input text                  enum.value.0.1                                          ${lot_non_price_2_value}
#    click element               xpath=(//*[@id="enumAddAction"])[1]
#    sleep  1
#    input text                  enum.title.0.2                                          ${lot_non_price_3_title}
#    input text                  enum.value.0.2                                          ${lot_non_price_3_value}
#
#    Execute Javascript    angular.element("md-tab-item")[3].click()
#    sleep  3
#    Execute Javascript    angular.element("md-tab-item")[2].click()
#    sleep  3
#
#    #заповнюємо нецінові крітерії тендеру
#    click element               featureAddAction
#    sleep  1
#    input text                  xpath=(//*[@id="feature.title."])[2]                    ${tender_features_title}
#    input text                  xpath=(//*[@id="feature.description."])[2]              ${tender_features_description}
#    select from list by value   xpath=(//*[@id="feature.featureOf."])[2]                ${tender_features_of}
#    sleep  2
#    click element               xpath=(//*[@id="enumAddAction"])[2]
#    sleep  1
#    input text                  enum.title.1.0                                          ${tender_non_price_1_title}
#    input text                  enum.value.1.0                                          ${tender_non_price_1_value}
#    click element               xpath=(//*[@id="enumAddAction"])[2]
#    sleep  1
#    input text                  enum.title.1.1                                          ${tender_non_price_2_title}
#    input text                  enum.value.1.1                                          ${tender_non_price_2_value}
#    click element               xpath=(//*[@id="enumAddAction"])[2]
#    sleep  1
#    input text                  enum.title.1.2                                          ${tender_non_price_3_title}
#    input text                  enum.value.1.2                                          ${tender_non_price_3_value}
#    Execute Javascript    angular.element("md-tab-item")[3].click()
#    sleep  3
#    Execute Javascript    angular.element("md-tab-item")[2].click()
#    sleep  3
#    #заповнюємо нецінові крітерії айтему
#    click element               featureAddAction
#    sleep  1
#    input text                  xpath=(//*[@id="feature.title."])[3]                    ${item_features_title}
#    input text                  xpath=(//*[@id="feature.description."])[3]              ${item_features_description}
#    select from list by value   xpath=(//*[@id="feature.featureOf."])[3]                ${item_features_of}
#    sleep  3
#    select from list by label   xpath=(//*[@id="feature.relatedItem."])[2]                ${item_description}
#    sleep  3
#    click element               xpath=(//*[@id="enumAddAction"])[3]
#    sleep  1
#    input text                  enum.title.2.0                                          ${item_non_price_1_title}
#    input text                  enum.value.2.0                                          ${item_non_price_1_value}
#    click element               xpath=(//*[@id="enumAddAction"])[3]
#    sleep  1
#    input text                  enum.title.2.1                                          ${item_non_price_2_title}
#    input text                  enum.value.2.1                                          ${item_non_price_2_value}
#    click element               xpath=(//*[@id="enumAddAction"])[3]
#    sleep  1
#    input text                  enum.title.2.2                                          ${item_non_price_3_title}
#    input text                  enum.value.2.2                                          ${item_non_price_3_value}

    # Переходимо на вкладку "Контактна особа"
    Execute Javascript    angular.element("md-tab-item")[3].click()
    sleep  3
    input text            procuringEntityContactPointName                               ${contact_point_name}
    input text            procuringEntityContactPointTelephone                          ${contact_point_phone}
    input text            procuringEntityContactPointFax                                ${contact_point_fax}
    input text            procuringEntityContactPointEmail                              ${contact_point_email}
    input text            procurementMethodDetails                                      ${acceleration_mode}
    input text            submissionMethodDetails                                       quick(mode:fast-forward)
    input text            mode                                                          test
    sleep  3
    click button  tender-apply
    sleep  3
    ${NewTenderUrl}=  Execute Javascript  return window.location.href

    log to console  ******************
    log to console  NewTenderUrl ${NewTenderUrl}

    SET GLOBAL VARIABLE  ${NewTenderUrl}
    sleep  4
    wait until element is visible  ${Поле "Узагальнена назва закупівлі"}  30
    click button  ${Кнопка "Опублікувати"}
    wait until element is visible  ${Кнопка "Так" у попап вікні}  60
    click element  ${Кнопка "Так" у попап вікні}
    wait until element is visible  xpath=//div[contains(text(),'Опубліковано')]  300
    ${localID}=    get_local_id_from_url        ${NewTenderUrl}
#    ${hrefToTender}=    Evaluate    "/etm-Qa_fe/dashboard/tender-drafts/" + str(${localID})

    ${hrefToTender}=    Evaluate    "/dashboard/tender-drafts/" + str(${localID})

    Wait Until Page Contains Element    xpath=//a[@href="${hrefToTender}"]    30
    Go to  ${NewTenderUrl}
	Wait Until Page Contains Element  id=tenderUID    15
	Wait Until Page Contains Element  id=tenderID     15
    ${tender_id}=  Get Text  xpath=//a[@id='tenderUID']
    ${TENDER_UA}=  Get Text  id=tenderID
    ${ViewTenderUrl}=  assemble_viewtender_url  ${NewTenderUrl}  ${tender_id}
    log to console  *************
    log to console  ViewTenderUrl ${ViewTenderUrl}
	SET GLOBAL VARIABLE  ${ViewTenderUrl}
    [return]  ${TENDER_UA}

Отримуємо код ДК
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  tender_data
  ${items}=                             Get From Dictionary             ${ARGUMENTS[0].data}                        items
  ${add_scheme}=                        Get From Dictionary             ${items[0].additionalClassifications[0]}    scheme
  ${add_id}=                            Get From Dictionary             ${items[0].additionalClassifications[0]}    id
  ${add_descr}=                         Get From Dictionary             ${items[0].additionalClassifications[0]}    description
  set global variable  ${add_scheme}
  set global variable  ${add_id}
  set global variable  ${add_descr}
  log to console  *
  log to console  Додатковий код
  log to console  ${add_scheme}
  log to console  ${add_id}
  log to console  ${add_descr}
  log to console  *

Заповнюємо додаткові коди
    Execute Javascript    angular.element("#cpv").scope().value.additionalClassifications = [{id: "${add_id}", description: "${add_descr}", scheme: "${add_scheme}"}];
    sleep  2

Оновити сторінку з тендером
    [Arguments]    @{ARGUMENTS}
    [Documentation]
    ...      ${ARGUMENTS[0]} = username
    ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
	Switch Browser    ${ARGUMENTS[0]}
	Run Keyword If   '${ARGUMENTS[0]}' == 'accept_Owner'   Go to    ${NewTenderUrl}

Пошук тендера по ідентифікатору
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER}
  #натискаємо кнопку пошук
  click element  xpath=(.//span[@class='ng-binding ng-scope'])[2]
  sleep  5
  # Кнопка  "Розширений пошук"
  Click Button    xpath=//tender-search-panel//div[@class='advanced-search-control']//button[contains(@ng-click, 'advancedSearchHidden')]
  sleep  2
  Input Text      id=identifier    ${ARGUMENTS[1]}
  Click Button    id=searchButton
  Sleep  10
  click element  xpath=(.//div[@class='resultItemHeader'])[1]/a
  sleep  10
  ${ViewTenderUrl}=    Execute Javascript    return window.location.href
  SET GLOBAL VARIABLE    ${ViewTenderUrl}
  sleep  1

Відповісти на вимогу про виправлення умов закупівлі
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${USERS.users['${provider}']['tender_claim_data']['complaintID']}
  ...      ${ARGUMENTS[3]} ==  ${answer_data}
  ${resolution}=            get from dictionary         ${ARGUMENTS[3].data}                    resolution
  ${resolutionType}=        get from dictionary         ${ARGUMENTS[3].data}                    resolutionType
  ${tendererAction}=        get from dictionary         ${ARGUMENTS[3].data}                    tendererAction
  go to                     ${ViewTenderUrl}
  sleep                     30
  reload page
  sleep  5
  execute javascript                    angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  wait until element is visible         id=old-complaint-answer-  60
  click element                         id=old-complaint-answer-
  wait until element is visible         id=resolution  60
  input text                            id=resolution                        ${resolution}
  select from list by value             resolutionType                       ${resolutionType}
  sleep  2
  input text                            tendererAction                       ${tendererAction}
  click element                         xpath=.//button[@ladda='vm.saving']
  sleep  10

Відповісти на вимогу про виправлення умов лоту
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${USERS.users['${provider}']['tender_claim_data']['complaintID']}
  ...      ${ARGUMENTS[3]} ==  ${answer_data}
  ${resolution}=            get from dictionary         ${ARGUMENTS[3].data}                        resolution
  ${resolutionType}=        get from dictionary         ${ARGUMENTS[3].data}                        resolutionType
  ${tendererAction}=        get from dictionary         ${ARGUMENTS[3].data}                        tendererAction
  go to  ${ViewTenderUrl}
  sleep  30
  reload page
  sleep  5
  execute javascript                    angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  wait until element is visible         id=old-complaint-answer-  60
  click element                         id=old-complaint-answer-
  wait until element is visible         id=resolution  60
  input text                            id=resolution                        ${resolution}
  select from list by value             resolutionType                       ${resolutionType}
  sleep  2
  input text                            tendererAction                       ${tendererAction}
  click element                         xpath=.//button[@ladda='vm.saving']
  sleep  10

Відповісти на вимогу про виправлення визначення переможця
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${USERS.users['${provider}']['claim_data']['complaintID']}
  ...      ${ARGUMENTS[3]} ==  ${answer_data}
  ...      ${ARGUMENTS[4]} ==  ${award_index}
  ${resolution}=            get from dictionary         ${ARGUMENTS[3].data}                        resolution
  ${resolutionType}=        get from dictionary         ${ARGUMENTS[3].data}                        resolutionType
  ${tendererAction}=        get from dictionary         ${ARGUMENTS[3].data}                        tendererAction
  go to  ${ViewTenderUrl}
  sleep  30
  reload page
  sleep  5
  execute javascript                    angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  wait until element is visible         id=old-complaint-answer-  60
  click element                         id=old-complaint-answer-
  wait until element is visible         id=resolution  60
  input text                            id=resolution                        ${resolution}
  select from list by value             resolutionType                       ${resolutionType}
  sleep  2
  input text                            tendererAction                       ${tendererAction}
  click element                         xpath=.//button[@ladda='vm.saving']
  sleep  10

Створити вимогу про виправлення умов закупівлі
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${claim}
  ...      ${ARGUMENTS[3]} ==  ${file_path}
  log to console  *
  log to console  !!! Починаємо "Створити вимогу про виправлення умов закупівлі" !!!
  ${title}=                      get from dictionary                   ${ARGUMENTS[2].data}        title
  ${description}=                get from dictionary                   ${ARGUMENTS[2].data}        description
  go to                          ${ViewTenderUrl}
  sleep  10
  wait until element is visible  claim-add  60
  sleep  3
  #Натискаємо кнопку "Створити вимогу"
  focus                          id=claim-add
  click element                  id=claim-add
  #Переходимо у вікно "Вимога до закупівлі"
#  wait until element is visible  title  60
  sleep  10
  focus                          title
  input text                     title                                 ${title}
  input text                     description                           ${description}
  sleep  2
  click element                  complaint-document-add
  sleep  5
  input text                     description-complaint-documents-0     PLACEHOLDER
  choose file                    id=file-complaint-documents-0         ${ARGUMENTS[3]}
  click element                  xpath=.//button[@type='submit']
  #Очікуємо появи повідомлення
  wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  5
  ${complaint_id}=               execute javascript   return angular.element("div:contains('${title}')").parent("a")[0].id
  ${delim}=                      convert to string    t-
  ${complaint_id}=               parse_smth           ${complaint_id}  ${1}  ${delim}
  log to console  *
  log to console  Створено вимогу номер ${complaint_id}
  log to console  *
  log to console  !!! Закінчили "Створити вимогу про виправлення умов закупівлі" !!!
  [return]  ${complaint_id}


Створити вимогу про виправлення умов лоту
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${claim}
  ...      ${ARGUMENTS[3]} ==  ${lot_id}
  ...      ${ARGUMENTS[4]} ==  ${file_path}
  log to console  *
  log to console  !!! Починаємо "Створити вимогу про виправлення умов лоту"  !!!
  ${title}=                      get from dictionary                   ${ARGUMENTS[2].data}        title
  ${description}=                get from dictionary                   ${ARGUMENTS[2].data}        description
  go to                          ${ViewTenderUrl}
  wait until element is visible  claim-add  60
  sleep  5
  #Натискаємо кнопку "Створити вимогу"
  click element  claim-add
  #Переходимо у вікно "Вимога до закупівлі"
  wait until element is visible  id=relatedLot  60
  #Обираємо лот до якого створюється вимога
  click element                  id=relatedLot
  sleep  2
  click element                  xpath=(.//option[@class='ng-binding ng-scope'])[1]
  sleep  2
  input text                     title                                 ${title}
  input text                     description                           ${description}
  sleep  2
  click element                  complaint-document-add
  sleep  1
  click element                  complaint-document-add
  sleep  3
  input text                              description-complaint-documents-0     PLACEHOLDER
  choose file                             id=file-complaint-documents-0         ${ARGUMENTS[4]}
  click element                           xpath=.//button[@type='submit']
  #Очікуємо появи повідомлення
  wait until element is visible         xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  15
  ${complaint_id}=  execute javascript   return angular.element("div:contains('${title}')").parent("a")[0].id
  ${delim}=  convert to string  t-
  ${complaint_id}=  parse_smth  ${complaint_id}  ${1}  ${delim}
  log to console  *
  log to console  Створено вимогу до лоту номер ${complaint_id}
  log to console  *
  log to console  !!! Закінчили "Створити вимогу про виправлення умов лоту"  !!!
  [return]  ${complaint_id}




Отримати інформацію із скарги
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${tender_uaid}
  ...      ${ARGUMENTS[2]} ==  ${complaintID}
  ...      ${ARGUMENTS[3]} ==  ${field_name}
  ...      ${ARGUMENTS[4]} ==  ${award_index}
#  sleep  5
  go to  ${ViewTenderUrl}
  sleep  5
  log to console  *
  log to console  ${ARGUMENTS[2]}
  log to console  *
  execute javascript             angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  ${return_value}=  run keyword  Отримати інформацію про ${ARGUMENTS[3]}
  [return]  ${return_value}

Отримати інформацію про description
   wait until element is visible        xpath=.//div[@class='description-text ng-binding ng-scope']  60
   ${return_value}=   get text          xpath=.//div[@class='description-text ng-binding ng-scope']
   [return]  ${return_value}

Отримати інформацію про title
   wait until element is visible        xpath=.//div[@class='description-text ng-binding ng-scope']  60
   ${return_value}=   get text          xpath=(.//div[@class='ng-binding flex'])[1]
   ${return_value}=   parse_smth        ${return_value}    ${1}   ${:}
   ${return_value}=   trim_data         ${return_value}
   [return]  ${return_value}

Отримати інформацію із документа до скарги
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${complaintID}
  ...      ${ARGUMENTS[3]} ==  ${doc_id}
  ...      ${ARGUMENTS[4]} ==  ${field}
  go to  ${ViewTenderUrl}
  sleep  10
  execute javascript                    angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  wait until element is visible         xpath=(.//button[@type='button']/span[@class='ng-binding ng-scope'])[9]  60
  click element                         xpath=(.//button[@type='button']/span[@class='ng-binding ng-scope'])[9]
  wait until element is visible         xpath=(.//a[@class='link-like ng-binding'])[8]   60
  ${return_value}=      get text        xpath=(.//a[@class='link-like ng-binding'])[8]
  [return]  ${return_value}

Отримати інформацію про status
   wait until element is visible        id=complaint-status  60
   ${return_value}=  get value          id=complaint-status
   [return]  ${return_value}

Отримати інформацію про resolutionType

   wait until element is visible        id=resolution-type  60
   ${return_value}=  get value          id=resolution-type
   [return]  ${return_value}

Отримати інформацію про resolution
   wait until element is visible        xpath=(.//div[@class='description-text ng-binding ng-scope'])[2]          60
   ${return_value}=  get text           xpath=(.//div[@class='description-text ng-binding ng-scope'])[2]
   [return]  ${return_value}

Отримати інформацію про satisfied
   wait until element is visible        xpath=.//div[@layout='row']/div[@flex='none']/span[@class='ng-binding']   60
   ${return_value}=  get text           xpath=.//div[@layout='row']/div[@flex='none']/span[@class='ng-binding']
   ${return_value}=  claim_status       ${return_value}

   [return]  ${return_value}

Отримати інформацію про cancellationReason
   wait until element is visible        xpath=.//div[@class='description-text ng-binding']     60
   ${return_value}=  get text           xpath=.//div[@class='description-text ng-binding']
   [return]  ${return_value}

Отримати інформацію про relatedLot
   wait until element is visible        id=related-lot  60
   ${return_value}=  get value          id=related-lot
   [return]  ${return_value}

Завантажити документ рішення кваліфікаційної комісії
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${file_path}
  ...      ${ARGUMENTS[2]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[3]} ==  ${0}
  go to  ${ViewTenderUrl}
  log to console  *
  log to console  ${ARGUMENTS[0]}
  log to console  ${ARGUMENTS[1]}
  log to console  ${ARGUMENTS[2]}
  log to console  ${ARGUMENTS[3]}
  log to console  *
  sleep  10
#  click element  id=award-active-0
  execute javascript  $($('[id=award-active-0]')[0]).click()
  wait until element is visible  xpath=.//button[@ng-click='onDocumentAdd()']  60
  sleep  1
  click element  xpath=.//button[@ng-click='onDocumentAdd()']
  wait until element is visible  ${Поле "Тип документа" (Кваліфікація учасників)}
  select from list  ${Поле "Тип документа" (Кваліфікація учасників)}  Повідомлення
  sleep  1
  input text  description-award-document  Назва документу
  choose file  id=file-award-document  ${ARGUMENTS[1]}
  sleep  2
  click element  xpath=/html/body/div[1]/div/div/form/ng-transclude/div[3]/button[1]
  sleep  10

Підтвердити постачальника
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${file_path}
  ...      ${ARGUMENTS[2]} ==  ${0}
  go to  ${ViewTenderUrl}

Отримати інформацію із лоту
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${object_id}
  ...      ${ARGUMENTS[3]} ==  ${field_name}
  go to  ${ViewTenderUrl}
  sleep  10
  ${return_value}=  get text  xpath=(.//div[@class='field-value word-break ng-binding flex-70'])[1]
  [return]  ${return_value}

Підтвердити вирішення вимоги про виправлення умов закупівлі
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${USERS.users['${provider}']['tender_claim_data']['complaintID']}
  ...      ${ARGUMENTS[3]} ==  ${confirmation_data}
  log to console  *
  log to console  !!! Починаємо "Підтвердити вирішення вимоги про виправлення умов закупівлі"  !!!
  go to  ${ViewTenderUrl}
  wait until element is visible         claim-add  60
  sleep  5
  execute javascript                    angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  #Кнопка "ПОГОДИТИСЬ З ВИРІШЕННЯМ"
  wait until element is visible         id=old-complaint-satisfy-  60
  click element                         id=old-complaint-satisfy-
  #кнопка "Погодитись з вирішенням"
  wait until element is visible         xpath=.//button[@type='submit']  60
  click element                         xpath=.//button[@type='submit']
  #Очікуємо появи повідомлення
  wait until element is visible         xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  5
  log to console  !!! Закінчили "Підтвердити вирішення вимоги про виправлення умов закупівлі"  !!!

Підтвердити вирішення вимоги про виправлення умов лоту
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${USERS.users['${provider}']['lot_claim_data']['complaintID']}
  ...      ${ARGUMENTS[3]} ==  ${confirmation_data}
  log to console  *
  log to console  !!! Починаємо "Підтвердити вирішення вимоги про виправлення умов лоту  !!!
  go to  ${ViewTenderUrl}
  wait until element is visible  claim-add  60
  sleep  5
  execute javascript                    angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  wait until element is visible         id=old-complaint-satisfy-  60
  #кнопка "ПОГОДИТИСЬ З ВИРІШЕННЯМ"
  click element                         id=old-complaint-satisfy-
  #кнопка "Погодитись з вирішенням"
  wait until element is visible         xpath=.//button[@type='submit']  60
  click element                         xpath=.//button[@type='submit']
  #Очікуємо появи повідомлення
  wait until element is visible         xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  5
  log to console  !!! Закінчили "Підтвердити вирішення вимоги про виправлення умов лоту  !!!

Створити чернетку вимоги про виправлення умов закупівлі
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${claim}
  log to console  *
  log to console  !!! Починаємо "Створити чернетку вимоги про виправлення умов закупівлі"  !!!
  ${title}=                      get from dictionary                   ${ARGUMENTS[2].data}        title
  ${description}=                get from dictionary                   ${ARGUMENTS[2].data}        description
  go to                          ${ViewTenderUrl}
  wait until element is visible  claim-add  60
  sleep  3

  #Натискаємо кнопку "Створити вимогу"
  click element  claim-add
  #Переходимо у вікно "Вимога до закупівлі"
  wait until element is visible  title  60
  input text                     title                                 ${title}
  input text                     description                           ${description}
  #Обираємо чекбокс "ПІДПИСАТИ"
  click element                  xpath=.//md-checkbox/div[@class='md-container']
  sleep  1
  #Кнопка "Створити вимогу"
  click element                  xpath=.//button[@type='submit']
  #Очікуємо появу поля "Пароль" та скасовуємо підписання
  wait until element is visible  id=PKeyPassword  120
  click element                  xpath=(.//button[@ng-click='cancel()'])[1]
  #Очікуємо появи повідомлення
  wait until element is visible         xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  15
  ${complaint_id}=  execute javascript   return angular.element("div:contains('${title}')").parent("a")[0].id
  ${delim}=  convert to string  t-
  ${complaint_id}=  parse_smth  ${complaint_id}  ${1}  ${delim}
  log to console  *
  log to console  Створили чернетку вимоги до закупівлі номер ${complaint_id}
  log to console  *
  log to console  !!! Закінчили "Створити чернетку вимоги про виправлення умов закупівлі"  !!!
  [return]  ${complaint_id}

Скасувати вимогу про виправлення умов закупівлі
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${USERS.users['${provider}']['tender_claim_data']['complaintID']}
  ...      ${ARGUMENTS[3]} ==  ${cancellation_data}
  log to console  *
  log to console  !!! Починаємо "Скасувати вимогу про виправлення умов закупівлі"  !!!
  ${cancellationReason}=         get from dictionary           ${ARGUMENTS[3].data}        cancellationReason
  go to  ${ViewTenderUrl}
  wait until element is visible  claim-add  60
  sleep  5
  execute javascript             angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  #Кнопка "ВІДКЛИКАТИ ВИМОГУ"
  wait until element is visible  id=old-complaint-cancel-  60
  click element                  id=old-complaint-cancel-
  wait until element is visible  id=cancellationReason     60
  input text                     id=cancellationReason     ${cancellationReason}
  sleep  1
  click element                  xpath=(.//button[@type='submit'])
  #Очікуємо появи повідомлення
  wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  5
  log to console  !!! Закінчили "Скасувати вимогу про виправлення умов закупівлі"  !!!

Створити чернетку вимоги про виправлення умов лоту
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${claim}
  ...      ${ARGUMENTS[3]} ==  ${lot_id}
  log to console  *
  log to console  !!! Починаємо "Створити чернетку вимоги про виправлення умов лоту"  !!!
  ${title}=                      get from dictionary                   ${ARGUMENTS[2].data}        title
  ${description}=                get from dictionary                   ${ARGUMENTS[2].data}        description
  go to  ${ViewTenderUrl}
  wait until element is visible  claim-add  60
  sleep  10
  #Натискаємо кнопку "Створити вимогу"
  click element                  claim-add
  #Переходимо у вікно "Вимога до закупівлі"
  wait until element is visible  title  60
  #Обираємо лот
  click element                  id=relatedLot
  sleep  2
  click element                  xpath=(.//option[@class='ng-binding ng-scope'])[1]
  sleep  2
  input text                     title                                 ${title}
  input text                     description                           ${description}
  #Обираємо чекбокс "ПІДПИСАТИ"
  click element                  xpath=.//md-checkbox/div[@class='md-container']
  sleep  1
  #Кнопка "Створити вимогу"
  click element                  xpath=.//button[@type='submit']
  #Очікуємо появу поля "Пароль" та скасовуємо підписання
  wait until element is visible  id=PKeyPassword  120
  click element                  xpath=(.//button[@ng-click='cancel()'])[1]
  #Очікуємо появи повідомлення
  wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  15
  ${complaint_id}=  execute javascript   return angular.element("div:contains('${title}')").parent("a")[0].id
  ${delim}=  convert to string  t-
  ${complaint_id}=  parse_smth  ${complaint_id}  ${1}  ${delim}
  log to console  *
  log to console  Створили чернетку вимоги до лоту номер ${complaint_id}
  log to console  *
  log to console  !!! Закінчили "Створити чернетку вимоги про виправлення умов лоту"  !!!
  [return]  ${complaint_id}

Перетворити вимогу про виправлення умов закупівлі в скаргу
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${USERS.users['${provider}']['tender_claim_data']['complaintID']}
  ...      ${ARGUMENTS[3]} ==  ${escalation_data}
  log to console  *
  log to console  !!! Починаємо "Перетворити вимогу про виправлення умов закупівлі в скаргу"  !!!
  go to  ${ViewTenderUrl}
  wait until element is visible  claim-add  60
  sleep  5
  execute javascript                     angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  #Кнопка "ПЕРЕТВОРИТИ ВИМОГУ В СКАРГУ"
  wait until element is visible          id=old-complaint-reject-  60
  click element                          id=old-complaint-reject-
  wait until element is visible          xpath=.//button[@ladda='vm.saving']  60
  click element                          xpath=.//button[@ladda='vm.saving']
  #Очікуємо появи повідомлення
  wait until element is visible          xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  5
  log to console  !!! Закінчили "Перетворити вимогу про виправлення умов закупівлі в скаргу"  !!!

Перетворити вимогу про виправлення умов лоту в скаргу
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${USERS.users['${provider}']['tender_claim_data']['complaintID']}
  ...      ${ARGUMENTS[3]} ==  ${escalation_data}
  log to console  *
  log to console  !!! Починаємо "Перетворити вимогу про виправлення умов лоту в скаргу"  !!!
  go to  ${ViewTenderUrl}
  wait until element is visible  claim-add  60
  sleep  5
  execute javascript                     angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  #Кнопка "ПЕРЕТВОРИТИ ВИМОГУ В СКАРГУ"
  wait until element is visible          id=old-complaint-reject-  60
  click element                          id=old-complaint-reject-
  wait until element is visible          xpath=.//button[@ladda='vm.saving']  60
  click element                          xpath=.//button[@ladda='vm.saving']
  #Очікуємо появи повідомлення
  wait until element is visible          xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  5
  log to console  !!! Закінчили "Перетворити вимогу про виправлення умов лоту в скаргу"  !!!

Отримати інформацію із тендера
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${field}
  go to  ${ViewTenderUrl}
  wait until element is visible            xpath=.//span[@ng-if='data.status']  60
  ${return_value}=  get element attribute  xpath=//*[@id="robotStatus"]@textContent
  log to console  *
  log to console  статус тендера= ${return_value}
  log to console  *
  [return]  ${return_value}

Подати цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${bid}
  ...      ${ARGUMENTS[3]} ==  ${lots_ids}
  ...      ${ARGUMENTS[4]} ==  ${features_ids}
  ${amount}=        get from dictionary            ${ARGUMENTS[2].data.lotValues[0].value}       amount
  ${amount_str}=    convert to string              ${amount}
  go to  ${ViewTenderUrl}
  wait until element is visible  xpath=.//span[@ng-if='data.status']  60
  #Кнопка "Додати пропозицію"
  execute javascript             angular.element("#set-participate-in-lot").click()
  sleep  3

  log to console  *
  ${test_var}=          get text            xpath=.//span[@dataanchor='amount']
  ${test_var}=          get_numberic_part   ${test_var}
  ${1_grn}=             set variable        ${1}
  ${test_var}=          evaluate            ${test_var}-${1_grn}
  ${test_var_str}=      convert to string   ${test_var}
  log to console   ${test_var_str}


  log to console  *

#  input text                     id=lot-amount-0       ${amount_str}
  input text                     id=lot-amount-0       ${test_var_str}
  sleep  5
  #Кнопка "Відправити пропозиції"
  execute javascript             angular.element("#tender-update-bid").click()
  wait until element is visible  xpath=.//button[@ng-click='ok()']  60
  click element                  xpath=.//button[@ng-click='ok()']
  sleep  10
  log to console  !!! Закінчили "Подати цінову пропозицію"  !!!

###############################################################################

Створити вимогу про виправлення визначення переможця
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${claim}
  ...      ${ARGUMENTS[3]} ==  ${award_index}
  ...      ${ARGUMENTS[4]} ==  ${file_path}
  log to console  *
  log to console  !!! Почали "Створити вимогу про виправлення визначення переможця"  !!!
  ${title}=                      get from dictionary                   ${ARGUMENTS[2].data}        title
  ${description}=                get from dictionary                   ${ARGUMENTS[2].data}        description

  go to  ${ViewTenderUrl}
  wait until element is visible  xpath=.//span[@ng-if='data.status']          60
  SLEEP  10
  execute javascript             angular.element("#award-claim-").click()
  wait until element is visible  id=title                 60
  input text                     id=title                 ${title}
  input text                     id=description           ${description}
  sleep  2
  click element                  complaint-document-add
  sleep  5
  input text                              description-complaint-documents-0     PLACEHOLDER
  choose file                             id=file-complaint-documents-0         ${ARGUMENTS[4]}
  click element                           xpath=.//button[@type='submit']
  #Очікуємо появи повідомлення
  wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  10
  ${complaint_id}=  execute javascript   return angular.element("div:contains('${title}')").parent("a")[0].id
  ${delim}=  convert to string  t-
  ${complaint_id}=  parse_smth  ${complaint_id}  ${1}  ${delim}
  log to console  *
  log to console  Вимога про виправлення переможця номер ${complaint_id}
  log to console  *
  log to console  !!! Закінчили "Створити вимогу про виправлення визначення переможця"  !!!
  [return]  ${complaint_id}


Підтвердити вирішення вимоги про виправлення визначення переможця
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  ${username}
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${USERS.users['${provider}']['claim_data']['complaintID']}
  ...      ${ARGUMENTS[3]} ==  ${confirmation_data}
  ...      ${ARGUMENTS[4]} ==  ${award_index}
  log to console  *
  log to console  !!! Підтвердити вирішення вимоги про виправлення визначення переможця  !!!
  go to  ${ViewTenderUrl}
  wait until element is visible         xpath=.//span[@ng-if='data.status']  60
  sleep  10
  execute javascript                    angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  wait until element is visible         id=old-complaint-satisfy-  60
  #кнопка "Погодитись з рішенням"
  click element                         id=old-complaint-satisfy-
  wait until element is visible         xpath=.//button[@ladda='vm.saving']  60
  click element                         xpath=.//button[@ladda='vm.saving']
  #Очікуємо появи повідомлення
  wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  5
  log to console  !!! Закінчили Підтвердити вирішення вимоги про виправлення визначення переможця  !!!

Створити чернетку вимоги про виправлення визначення переможця
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${claim}
  ...      ${ARGUMENTS[3]} ==  ${award_index}
  log to console  *
  log to console  !!! Починаємо "Створити чернетку вимоги про виправлення визначення переможця"  !!!
  ${title}=                      get from dictionary                   ${ARGUMENTS[2].data}        title
  ${description}=                get from dictionary                   ${ARGUMENTS[2].data}        description
  go to  ${ViewTenderUrl}
  #Натискаємо кнопку "Створити вимогу"
  wait until element is visible  xpath=.//span[@ng-if='data.status']  60
  sleep  10
  execute javascript             angular.element("#award-claim-").click()
  #Переходимо у вікно "Вимога до закупівлі"
  wait until element is visible  title  60
  input text                     title                                 ${title}
  input text                     description                           ${description}
  #Обираємо чекбокс "ПІДПИСАТИ"
  click element                  xpath=.//md-checkbox/div[@class='md-container']
  sleep  1
  #Кнопка "Створити вимогу"
  click element                  xpath=.//button[@type='submit']
  #Очікуємо появу поля "Пароль" та скасовуємо підписання
  wait until element is visible  id=PKeyPassword  120
  click element                  xpath=(.//button[@ng-click='cancel()'])[1]
  #Очікуємо появи повідомлення
  wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  10
  ${complaint_id}=  execute javascript   return angular.element("div:contains('${title}')").parent("a")[0].id
  ${delim}=  convert to string  t-
  ${complaint_id}=  parse_smth  ${complaint_id}  ${1}  ${delim}
  log to console  *
  log to console  Чернетка вимоги про виправлення визначення переможця номер ${complaint_id}
  log to console  *
  log to console  !!! Закінчили "Створити чернетку вимоги про виправлення визначення переможця"  !!!
  [return]  ${complaint_id}

Скасувати вимогу про виправлення визначення переможця
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${USERS.users['${provider}']['tender_claim_data']['complaintID']}
  ...      ${ARGUMENTS[3]} ==  ${cancellation_data}
  ...      ${ARGUMENTS[4]} ==  ${award_index}
  log to console  *
  log to console  !!! Починаємо "Скасувати вимогу про виправлення визначення переможця"  !!!
  ${cancellationReason}=       get from dictionary  ${ARGUMENTS[3].data}        cancellationReason
  go to  ${ViewTenderUrl}
  wait until element is visible  xpath=.//span[@ng-if='data.status']  60
  sleep  10
  execute javascript                     angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  wait until element is visible          id=old-complaint-cancel-  60
  click element                          id=old-complaint-cancel-
  wait until element is visible          id=cancellationReason     60
  input text      id=cancellationReason  ${cancellationReason}
  sleep  1
  click element                  xpath=(.//button[@type='submit'])
  #Очікуємо появи повідомлення
  wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  5
  log to console  !!! Закінчили "Скасувати вимогу про виправлення визначення переможця"  !!!

Перетворити вимогу про виправлення визначення переможця в скаргу
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${USERS.users['${provider}']['tender_claim_data']['complaintID']}
  ...      ${ARGUMENTS[3]} ==  ${escalation_data}
  ...      ${ARGUMENTS[4]} ==  ${award_index}
  log to console  *
  log to console  !!! Починаємо "Перетворити вимогу про виправлення визначення переможця в скаргу"  !!!
  go to  ${ViewTenderUrl}
  wait until element is visible  xpath=.//span[@ng-if='data.status']  60
  sleep  10
  execute javascript                     angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  #Кнопка "ПЕРЕТВОРИТИ ВИМОГУ В СКАРГУ"
  wait until element is visible          id=old-complaint-reject-  60
  click element                          id=old-complaint-reject-
  wait until element is visible          xpath=.//button[@ladda='vm.saving']  60
  click element                          xpath=.//button[@ladda='vm.saving']
  #Очікуємо появи повідомлення
  wait until element is visible          xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  5
  log to console  !!! Закінчили "Перетворити вимогу про виправлення визначення переможця в скаргу"  !!!

Скасувати вимогу про виправлення умов лоту
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER['TENDER_UAID']}
  ...      ${ARGUMENTS[2]} ==  ${USERS.users['${provider}']['tender_claim_data']['complaintID']}
  ...      ${ARGUMENTS[3]} ==  ${cancellation_data}
  log to console  *
  log to console  !!! Починаємо "Скасувати вимогу про виправлення умов лоту"  !!!
  ${cancellationReason}=       get from dictionary    ${ARGUMENTS[3].data}        cancellationReason
  go to  ${ViewTenderUrl}
  wait until element is visible  claim-add  60
  sleep  5
  execute javascript                     angular.element("[id*='complaint-${ARGUMENTS[2]}']")[0].click()
  #Кнопка "ВІДКЛИКАТИ ВИМОГУ"
  wait until element is visible  id=old-complaint-cancel-  60
  click element                  id=old-complaint-cancel-
  wait until element is visible  id=cancellationReason
  input text                     id=cancellationReason     ${cancellationReason}
  sleep  1
  click element                  xpath=(.//button[@type='submit'])
  #Очікуємо появи повідомлення
  wait until element is visible  xpath=.//div[@class='growl-container growl-fixed top-right']  120
  sleep  5
  log to console  !!! Закінчили "Скасувати вимогу про виправлення умов лоту"  !!!








