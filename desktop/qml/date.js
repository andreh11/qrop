.pragma library

function firstMonday(year) {
    var date = new Date(year, 0, 1)
    var dayn = (date.getDay() + 6) % 7;
    date.setDate(date.getDate() - dayn);
    return date
}

function addDays(date, days) {
    var result = new Date(date);
    result.setDate(date.getDate() + days);
    return result;
}

function mondayOfWeek(week, year) {
    return addDays(firstMonday(year), (week - 1) * 7);
}

function isoWeek(dt)
{
    var tdt = new Date(dt.valueOf());
    var dayn = (dt.getDay() + 6) % 7;
    tdt.setDate(tdt.getDate() - dayn + 3);
    var firstThursday = tdt.valueOf();
    tdt.setMonth(0, 1);
    if (tdt.getDay() !== 4) {
        tdt.setMonth(0, 1 + ((4 - tdt.getDay()) + 7) % 7);
    }
    return 1 + Math.ceil((firstThursday - tdt) / 604800000);
}

function week(date) {
    var target = new Date(date.valueOf())
    var dayNr = (date.getDay() + 6) % 7
    target.setDate(target.getDate() - dayNr + 3)
    var firstThursday = target.valueOf()
    target.setMonth(0, 1)
    if (target.getDay() !== 4) {
        target.setMonth(0, 1 + ((4 - target.getDay()) + 7) % 7)
    }
    var retVal = 1 + Math.ceil((firstThursday - target) / 604800000)

    return (retVal < 10 ? '0' + retVal : retVal)
}

function formatDate(date, currentYear) {
    var year = date.getFullYear();
    var text = week(date);
    var prefix = "";

    if (year < currentYear) {
        prefix += "< ";
    } else  if (year > currentYear) {
        prefix += "> ";
    }

    return prefix + text;
}

function season(date) {
    var month = date.getMonth();
    if (2 <= month && month <= 4)
        return 0;
    else if (5 <= month && month <= 7)
        return 1;
    else if (8 <= month && month <= 10)
        return 2;
    else
        return 3;
}

function seasonBeginning(season, year) {
    switch (season) {
    case 0:
        return new Date(year - 1, 9, 1);
    case 1:
        return new Date(year, 0, 1);
    case 2:
        return new Date(year, 3, 1);
    default:
        return new Date(year, 6, 1);
    }

}
