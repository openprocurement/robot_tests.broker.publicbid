# -*- coding: utf-8 -*-


def get_budget(data):
    amount = data['value']['amount']
    return str(amount)


def get_step_rate(data):
    amount = data['minimalStep']['amount']
    return str(amount)


def adapt_data(data):
    data['data']['procuringEntity']['name'] = 'TestOrg'
    for item in data['data']['items']:
        item['deliveryAddress']['region'] = u"м.Київ"
        item['deliveryAddress']['locality'] = u"м.Київ"
    return data

