local Translations = {
    error = {
        notenooughinv = 'Bu öğeden yeterince yok..',
        notenooughstock = 'Stokta bu kadar yok..',
        error404item = 'Bu öğeye veya bu miktarı sahip değilsiniz..',
        notworkinghere = 'Burada çalışmıyorsun..',
        notonduty = 'Görevde değilsiniz!',
        notboss = 'Burada patron siz değilsiniz..',
        nonegativeprice = 'Fiyat 0\'dan düşük olamaz..',
        broke = 'Yeterince paranız yok..',
        buycantbezero = '0 satın alamazsınız..',
    },
    success = {
        refillstock = 'Stoğa %{value} x %{value2} eklediniz',
        stockrefilled = 'Stok kaydedildi!',
        successbuy = '%{value} x %{value2} için %{value3} ödeyerek satın aldınız',
        setprice = '%{value} ürününü %{value2} fiyatından satışa çıkardınız',
        boughtshop = 'Bu dükkanı %{value} ödeyerek satın aldınız',
        removedstock = 'Dükkan stokundan çıkarıldı'
    },
    info = {
        openshop = 'Dükkanı Aç',
        manageshop = 'Dükkanı Yönet',
        dutychange = 'Göreve başla/bitir',
        onduty = 'Görevdesiniz',
        offduty = 'Görevde değilsiniz',
        emptyshop = 'Bu dükkan boş..',
    },
    managefunds = {
        header = 'Para Yönetimi',
        deposit = 'Nakit yatır',
        withdraw = 'Nakit çek',
        close = 'Kapat',
        depositdesc = 'Dükkanınıza nakit para yatırın',
        withdrawdesc = 'Dükkanınızdan nakit para çekin',
        depositheader = 'Nakit Yatır',
        depositamount = 'Ne kadar yatırıyorsunuz?',
        depositsubmit = 'Yatır',
        withdrawheader = 'Nakit Çek',
        withdrawamount = 'Ne kadar çekiyorsunuz?',
        withdrawsubmit = 'Çek'
    },
    managemenu = {
        buyshopheader = 'Bunu satın almak istediğinizden emin misiniz?',
        buyshop = 'Dükkanı %{value} karşılığında satın al',
        header = 'Dükkanı Yönet',
        checkstock = 'Stoğu Yönet </br> Stoğunuzu görüntüleyin / Değiştirin',
        restock = 'Dükkanı doldur',
        close = 'Kapat',
        inventory = 'Envanter',
        buyheader = 'Dükkan',
        amount = 'Miktar: ',
        confirm = 'Onayla',
        stockamount = 'Stoğa ne kadar %{value} eklemek istiyorsunuz? (Sahip olduğunuz: %{value2})',
        amountstock = 'Miktar',
        instock = 'Stoğunuzu yönetin </br> Fiyatı değiştirmek için bir şeye tıklayın',
        goback = 'Geri Dön',
        buyamount = '%{value} ne kadar satın almak istiyorsunuz? </br> %{value2}/parça </br> Stok: %{value3}',
        price = '%{value} bir parça',
        buy = 'Satın Al',
        whatprice = '%{value} ürününü ne kadar bir fiyattan satmak istiyorsunuz?',
        setprice = 'Fiyatı Belirle',
        howmuch = 'Parça başına ne kadar?',
        priceperlabel = 'Fiyat: %{value}',
        removestock = 'Stoktan çıkar',
        amountremove = 'Çıkarılacak miktar',
        removeamount = 'Dükkandan çıkar',
        managefunds = 'Banka'    
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
