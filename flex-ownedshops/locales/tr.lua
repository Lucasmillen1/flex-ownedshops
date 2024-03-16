local Translations = {
    error = {
        notenooughinv = 'Bu eşyadan yeterince yok..',
        notenooughstock = 'Stokta bu kadar yok..',
        error404item = 'Bu ürüne veya bu miktara sahip değilsiniz..',
        notworkinghere = 'Burada çalışmıyorsunuz..',
        notonduty = 'Görevde değilsiniz!',
        notboss = 'Burasının patronu siz değilsiniz..',
        nonegativeprice = 'Fiyat 0\'dan düşük olamaz..',
        broke = 'Yeterince paranız yok..',
        buycantbezero = '0 alamazsınız..',
    },
    success = {
        refillstock = 'Stoğa %{value} x %{value2} eklendi',
        stockrefilled = 'Stok kaydedildi!',
        successbuy = ' %{value} x %{value2} satın aldınız, %{value3}$ ödediniz',
        setprice = ' %{value} fiyatıyla %{value2} satışa çıkardınız',
        boughtshop = 'Bu dükkanı %{value}$ karşılığında satın aldınız',
    },
    info = {
        openshop = 'Dükkanı Aç',
        manageshop = 'Dükkanı Yönet',
        dutychange = 'Görevde/İşte Değişiklik Yap',
        onduty = 'Görevdesiniz',
        offduty = 'Görevde Değilsiniz',
        emptyshop = 'Bu dükkan boş..',
    },
    managemenu = {
        buyshopheader = 'Bunu satın almak istediğinizden emin misiniz?',
        buyshop = 'Dükkanı %{value}$ karşılığında satın al',
        header = 'Dükkanı Yönet',
        checkstock = 'Stoğu Yönet </br> Stoğunuzu Görüntüleyin/Değiştirin',
        restock = 'Dükkanı Doldur',
        close = 'Kapat',
        inventory = 'Envanter',
        buyheader = 'Dükkan',
        amount = 'Miktar: ',
        confirm = 'Onayla',
        stockamount = 'Stoğa ne kadar %{value} eklemek istersiniz? (Sizde: %{value2})',
        amountstock = 'Miktar',
        instock = 'Stoğunuzu yönetin </br> Bir şeyin fiyatını değiştirmek için tıklayın',
        goback = 'Geri Dön',
        buyamount = 'Ne kadar %{value} satın almak istersiniz? </br> %{value2}$ / adet </br> Stoğunuz: %{value3}',
        price = 'Adet başına %{value}$',
        buy = 'Satın Al',
        whatprice = '%{value} için ne kadar $\'a satmak istiyorsunuz?',
        setprice = 'Onayla',
        howmuch = 'Adet başına ne kadar $?',
        priceperlabel = 'Fiyat: %{value}',
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
