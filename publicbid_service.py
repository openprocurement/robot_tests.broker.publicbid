# coding=utf-8
from datetime import datetime
import dateutil.parser
import json
import pytz
import os
import urllib
from robot.libraries.BuiltIn import BuiltIn

TZ = pytz.timezone('Europe/Kiev')


def convert_date(date_str, from_pattern, to_pattern):
    date_str = datetime.strptime(date_str, from_pattern)
    date = datetime(date_str.year, date_str.month, date_str.day, date_str.hour, date_str.minute, date_str.second,
                    date_str.microsecond)
    return_date = date.strftime(to_pattern)
    return return_date


def get_tender_code(key):
    tender_status_codes = {
        "Період аукціону": "active.auction",
        "Очікування пропозицій": "active.tendering",
        "Кваліфікація переможця": "active.qualification",
        "Аукціон не відбувся": "unsuccessful",
        "Відмінений аукціон": "cancelled",
        "Завершений аукціон": "complete"
    }
    return tender_status_codes[unicode(key).encode('utf-8')]


def get_awards_status(key):
    award_status = {
        "Очікується завантаження протоколу": "pending.verification",
        "Очікування кваліфікації переможця": "pending.waiting",
        "Очікується оплата": "pending.payment",
        "Визнано переможцем": "active",
        "Скасовано": "cancelled",
        "Відхилено" : "unsuccessful"
    }
    return award_status[unicode(key).encode('utf-8')]


def get_tender_type(key):
    tender_types = {
        "Майно банків": "dgfOtherAssets",
        "Права вимоги": "dgfFinancialAssets",
        "Голландський аукціон": "dgfInsider"
    }
    return tender_types[unicode(key).encode('utf-8')]


def get_cancellation_code(key):
    cancellation_codes = {
        "Скасування активоване": "active"
    }
    return cancellation_codes[unicode(key).encode('utf-8')]


def parse_date(date_str):
    date_str = datetime.strptime(date_str, "%d.%m.%Y %H:%M")
    date = datetime(date_str.year, date_str.month, date_str.day, date_str.hour, date_str.minute, date_str.second,
                    date_str.microsecond)
    date = TZ.localize(date).isoformat()
    return date


def parse_item_date(date_str):
    date_str = datetime.strptime(date_str, "%d.%m.%Y")
    date = datetime(date_str.year, date_str.month, date_str.day)
    date = TZ.localize(date).isoformat()
    return date


def convert_date_to_string(date):
    date = dateutil.parser.parse(date)
    date = date.strftime("%d.%m.%Y %H:%M")
    return date


def convert_item_date_to_string(date):
    date = dateutil.parser.parse(date)
    date = date.strftime("%d.%m.%Y")
    return date


def capitalize_first_letter(string):
    string = string.lower()
    string = string.capitalize()
    return string


def get_field_id(field_id):
    fields = {
        'value.amount': 'mForm:budget',
        'minimalStep.amount': 'mForm:step',
        'title': 'mForm:name'
    }
    return fields[field_id]


def string_replace(value, from_text, to_text):
    value = value.encode('ascii', 'ignore')
    return value.replace(from_text, to_text)



def get_field_value(field_id, field_value):
    values = {
        'value.amount': field_value['amount'],
        'minimalStep.amount': field_value['amount'],
        'title': field_value
    }

    return values[field_id]


def get_document_field_xpath_by_id(field_id, document_id):
    values = {
        'title': "//a[contains(text(), '" + document_id + "')]",
        'description': "//a[contains(text(), '" + document_id + "')]/ancestor::tr[1]/td[3]/span"
    }
    return values[field_id]


def get_document_field_xpath_by_index(index, field):
    values = {
        "documentType": "//div[@id='mForm:pnlFiles']/div[3]/div/div/table/tbody/tr[@data-ri='" + str(index) + "']/td[2]/span"
    }
    return values[field]


def get_proposal_document_type(key):
    proposal_document_types = {
        "Протокол аукціону": "auctionProtocol",
        "Ліцензія": "license"
    }
    return proposal_document_types[unicode(key).encode('utf-8')]


def is_qualified(bid_data):
    if 'qualified' in bid_data['data']:
        return False
    return True


def get_award_index(index, awards_count):
    index = int(index)
    awards_count = int(awards_count)

    if index < 0:
        return awards_count + index
    else:
        return index


def get_question_xpath(field, question_id):
    values = {
        'title': "//span[contains(text(), '" + question_id + "')]/ancestor::tr/td[1]/span[1]",
        'description': "//span[contains(text(), '" + question_id + "')]/ancestor::tr/td[1]/span[2]"
    }
    return values[field]


def get_question_answer_by_type_xpath(question_type, index):
    if question_type == 'question':
        identifier = ((int(index) + 1) * 2) - 2
    else:
        identifier = ((int(index) + 1) * 2) - 1

    xpath = "//*[@id='mForm:data:" + str(identifier) + ":description']"
    return xpath


def download_file(url, file_name):
    output_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    urllib.urlretrieve(url, os.path.join(output_dir, file_name))


def get_document_type_xpath(doc_type):
    doc_type_xpath = {
        "illustration": "//*[@id='mForm:docCard:dcType_1']",
        "doc": "//*[@id='mForm:docCard:dcType_3']",
        "tenderNotice": "//*[@id='mForm:docCard:dcType_4']",
        "x_presentation": "//*[@id='mForm:docCard:dcType_3']",
        "technicalSpecifications": "//*[@id='mForm:docCard:dcType_2']",
        "x_nda": "//*[@id='mForm:docCard:dcType_5']"
    }
    return doc_type_xpath[doc_type]


def get_document_link_type_xpath(doc_type):
    doc_link_type_xpath = {
        "x_dgfPublicAssetCertificate": "//li[@id='mForm:docCard:dcType_1']",
        "vdr": "//li[@id='mForm:docCard:dcType_2']"
    }
    return doc_link_type_xpath[doc_type]


def get_tender_attempts_xpath(tender_data):
    values = {
        1: "//*[@id='mForm:tenderAttempts_1']",
        2: "//*[@id='mForm:tenderAttempts_2']",
        3: "//*[@id='mForm:tenderAttempts_3']",
        4: "//*[@id='mForm:tenderAttempts_4']"
    }
    if 'tenderAttempts' not in tender_data:
        return "//*[@id='mForm:tenderAttempts_0']"
    else:
        return values[tender_data['tenderAttempts']]


def get_document_type(key):
    values = {
        "Юридична Інформація Майданчиків": "x_dgfPlatformLegalDetails"
    }
    return values.get(unicode(key).encode('utf-8'), '')


def get_tender_attempts(key):
    values = {
        "Лот виставляється вперше": 1
    }
    return values.get(unicode(key).encode('utf-8'), None)
