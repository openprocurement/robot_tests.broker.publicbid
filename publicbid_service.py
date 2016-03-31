# coding=utf-8
from datetime import datetime
import dateutil.parser
import json
import pytz

TZ = pytz.timezone('Europe/Kiev')


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


def to_int(value):
    return int(value)


def change_data(initial_data):
    initial_data['data']['procuringEntity']['name'] = u"Тестова Закупівля"
    initial_data['data']['items'][0]['deliveryAddress']['locality'] = u"м. Київ"
    initial_data['data']['items'][0]['deliveryAddress']['region'] = u"м. Київ"
    initial_data['data']['items'][0]['deliveryAddress']['countryName'] = u"Україна"
    initial_data['data']['items'][0]['deliveryLocation']['latitude'] = u"49.85"
    initial_data['data']['items'][0]['deliveryLocation']['longitude'] = u"24.0167"
    initial_data['data']['items'][0]['unit']['name'] = u"кілограми"
    return initial_data

