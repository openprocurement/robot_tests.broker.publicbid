# coding=utf-8
from datetime import datetime
import dateutil.parser
import json
import pytz

TZ = pytz.timezone('Europe/Kiev')

tenderCodes = {
    "Період аукціону": "active.auction",
    "Очікування пропозицій": "active.tendering",
    "Кваліфікація переможця": "active.qualification",
    "Аукціон не відбувся": "unsuccessful"
}

cancellationCodes = {
    "Скасування активоване": "active"
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
        'value.amount':  field_value['amount'],
        'minimalStep.amount': field_value['amount'],
        'title': field_value
    }

    return values[field_id]


def get_cancellation_field_id(field_id):
    values = {
        'title': 'mForm:cancellation-docs:dg-data-table:0:dg-file-api-lnk',
        'description': 'mForm:cancellation-docs:dg-data-table:0:dg-description-text'
    }

    return values[field_id]









