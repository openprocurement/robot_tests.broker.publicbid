# -*- coding: utf-8 -*-
tenderCodes = {
    "Період аукціону": "active.auction",
    "Очікування пропозицій": "active.tendering"
}


def get_tender_code(key):
    return tenderCodes[unicode(key).encode('utf-8')]


def get_budget(data):
    amount = data['value']['amount']
    return str(amount)


def adapt_data(data):
    data['data']['procuringEntity']['name'] = 'TestOrg'
    data['data']['items'][0]['deliveryAddress']['region'] = u"м.Київ"
    data['data']['items'][0]['deliveryAddress']['locality'] = u"Райони М. київ"
    return data

