# coding=utf-8
from datetime import datetime
import dateutil.parser
import json
import pytz

TZ = pytz.timezone('Europe/Kiev')


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


def convert_date(date_str, from_pattern, to_pattern):
    date_str = datetime.strptime(date_str, from_pattern)
    date = datetime(date_str.year, date_str.month, date_str.day, date_str.hour, date_str.minute, date_str.second,
                    date_str.microsecond)
    return_date = date.strftime(to_pattern)
    return return_date


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


def string_replace(value, from_text, to_text):
    value = value.encode('ascii', 'ignore')
    return value.replace(from_text, to_text)



