local Translations = {
    error = {
        notenooughinv = 'Je hebt niet genoeg van dit item..',
        notenooughstock = 'Er is niet zoveel op voorraad..',
        error404item = 'Je hebt dit item niet of niet in deze hoeveelheid..',
        notworkinghere = 'Je werkt hier niet..',
        notonduty = 'Je bent niet aan het werk!',
        notboss = 'Jij bent niet de baas hier..',
        nonegativeprice = 'De prijs kan niet lager zijn dan 0..',
        broke = 'Je hebt niet genoeg geld..',
        buycantbezero = 'Je kunt niet 0 kopen..',
    },
    success = {
        refillstock = 'Je hebt %{value} x %{value2} aan voorraad toegevoegd',
        stockrefilled = 'Voorraad is bijgewerkt!',
        successbuy = 'Je hebt %{value} x %{value2} gekocht voor $%{value3}',
        setprice = 'Je hebt %{value} te koop gezet voor $%{value2}',
        boughtshop = 'Je hebt deze winkel gekocht voor $%{value}',
    },
    info = {
        openshop = 'Winkel Openen',
        manageshop = 'Winkel Beheren',
        dutychange = 'Aan/uit dienst gaan',
        onduty = 'Je bent aan het werk',
        offduty = 'Je bent niet aan het werk',
        emptyshop = 'Deze winkel is leeg..',
    },
    managemenu = {
        buyshopheader = 'Weet je zeker dat je dit wilt kopen?',
        buyshop = 'Koop winkel voor $%{value}',
        header = 'Winkel Beheren',
        checkstock = 'Voorraad Beheren </br> Bekijk / Verander je voorraad',
        restock = 'Toevoegen aan winkel',
        close = 'Sluiten',
        inventory = 'Inventaris',
        buyheader = 'Winkel',
        amount = 'Aantal: ',
        confirm = 'Bevestigen',
        stockamount = 'Hoeveel %{value} wil je toevoegen aan de voorraad? (Je hebt: %{value2})',
        amountstock = 'Aantal',
        instock = 'Beheer je voorraad </br> Klik op iets om de prijs te wijzigen',
        goback = 'Terug',
        buyamount = 'Hoeveel %{value} wil je kopen? </br> $%{value2}/stuk </br> Voorraad: %{value3}',
        price = '$%{value} per stuk',
        buy = 'Kopen',
        whatprice = 'Voor hoeveel in $ wil je %{value} verkopen?',
        setprice = 'Bevestigen',
        howmuch = 'Hoeveel $ per stuk?',
        priceperlabel = 'Prijs: %{value}',
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
