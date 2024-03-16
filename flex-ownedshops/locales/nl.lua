local Translations = {
    error = {
        notenooughinv = 'Je hebt niet genoeg van dit item..',
        notenooughstock = 'Er is niet zoveel op voorraad..',
        error404item = 'Je hebt dit item of deze hoeveelheid niet..',
        notworkinghere = 'Je werkt hier niet..',
        notonduty = 'Je bent niet aan dienst!',
        notboss = 'Je bent hier niet de baas..',
        nonegativeprice = 'De prijs kan niet lager zijn dan 0..',
        broke = 'Je hebt niet genoeg geld..',
        buycantbezero = 'Je kunt niet 0 kopen..',
    },
    success = {
        refillstock = 'Je hebt %{value} x %{value2} aan de voorraad toegevoegd',
        stockrefilled = 'Voorraad is opgeslagen!',
        successbuy = 'Je hebt %{value} x %{value2} gekocht voor %{value3}',
        setprice = 'Je hebt %{value} te koop gezet voor %{value2}',
        boughtshop = 'Je hebt deze winkel gekocht voor %{value}',
        removedstock = 'Verwijderd uit winkel'
    },
    info = {
        openshop = 'Open Winkel',
        manageshop = 'Beheer Winkel',
        dutychange = 'Ga aan/uit dienst',
        onduty = 'Je bent aan dienst',
        offduty = 'Je bent uit dienst',
        emptyshop = 'Deze winkel is leeg..',
    },
    managefunds = {
        header = 'Geldbeheer',
        deposit = 'Geld storten',
        withdraw = 'Geld opnemen',
        close = 'Sluiten',
        depositdesc = 'Geld in je winkel storten',
        withdrawdesc = 'Geld uit je winkel opnemen',
        depositheader = 'Geld Storten',
        depositamount = 'Hoeveel ga je storten?',
        depositsubmit = 'Storten',
        withdrawheader = 'Geld Opnemen',
        withdrawamount = 'Hoeveel neem je op?',
        withdrawsubmit = 'Opnemen'
    },
    managemenu = {
        buyshopheader = 'Weet je zeker dat je dit wilt kopen?',
        buyshop = 'Winkel kopen voor %{value}',
        header = 'Winkel Beheren',
        checkstock = 'Voorraad Beheren </br> Bekijk / Verander je voorraad',
        restock = 'Toevoegen aan winkel',
        close = 'Sluiten',
        inventory = 'Inventaris',
        buyheader = 'Winkel',
        amount = 'Hoeveelheid: ',
        confirm = 'Bevestigen',
        stockamount = 'Hoeveel %{value} wil je aan de voorraad toevoegen? (Je hebt: %{value2})',
        amountstock = 'Hoeveelheid',
        instock = 'Beheer je voorraad </br> Klik op iets om de prijs te wijzigen',
        goback = 'Ga Terug',
        buyamount = 'Hoeveel %{value} wil je kopen? </br> %{value2}/stuk </br> Op voorraad: %{value3}',
        price = '%{value} per stuk',
        buy = 'Kopen',
        whatprice = 'Voor hoeveel wil je %{value} verkopen?',
        setprice = 'Bevestig',
        howmuch = 'Hoeveel per stuk?',
        priceperlabel = 'Prijs: %{value}',
        removestock = 'Voorraad verwijderen',
        amountremove = 'Hoeveelheid verwijderen',
        removeamount = 'Uit winkel halen',
        managefunds = 'Bank'    
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
