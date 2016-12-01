# coding=utf-8
from datetime import datetime
import dateutil.parser
import json
import pytz
import os
import urllib
from robot.libraries.BuiltIn import BuiltIn

TZ = pytz.timezone('Europe/Kiev')

tenderCodes = {
    "Період аукціону": "active.auction",
    "Очікування пропозицій": "active.tendering",
    "Кваліфікація переможця": "active.qualification",
    "Аукціон не відбувся": "unsuccessful",
    "Відмінений аукціон": "cancelled",
    "Завершений аукціон": "complete"
}

cancellationCodes = {
    "Скасування активоване": "active"
}

proposalDocumentTypes = {
    "Протокол аукціону": "auctionProtocol",
    "Ліцензія": "license"
}


def get_tender_code(key):
    return tenderCodes[unicode(key).encode('utf-8')]


def get_cancellation_code(key):
    return cancellationCodes[unicode(key).encode('utf-8')]


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


def get_field_value(field_id, field_value):
    values = {
        'value.amount': field_value['amount'],
        'minimalStep.amount': field_value['amount'],
        'title': field_value
    }

    return values[field_id]


def get_document_field_xpath(field_id, document_id):
    values = {
        'title': "//a[contains(text(), '" + document_id + "')]",
        'description': "//a[contains(text(), '" + document_id + "')]/ancestor::tr[1]/td[3]/span"
    }
    return values[field_id]


def get_proposal_document_type(key):
    return proposalDocumentTypes[unicode(key).encode('utf-8')]


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
