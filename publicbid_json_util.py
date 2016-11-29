# -*- coding: utf-8 -*-


def get_budget(data):
    amount = data['value']['amount']
    return str(amount)


def get_step_rate(data):
    amount = data['minimalStep']['amount']
    return str(amount)


def adapt_data(data):
    data['data']['procuringEntity']['name'] = 'TestOrg'
    data['data']['items'][0]['deliveryAddress']['region'] = u"м.Київ"
    data['data']['items'][0]['deliveryAddress']['locality'] = u"м.Київ"
    return data

