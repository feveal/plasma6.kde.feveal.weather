
function getLastReloadedTimeText(lastReloaded) {
    var mins = lastReloaded / 60000
    if (mins <= 180) {
        return i18n("%1 min ago", Math.round(mins))
    }

    var hours = mins / 60
    if (hours <= 48) {
        return i18n("%1 hrs ago", Math.round(hours))
    }

    var days = hours / 24
    if (days <= 14) {
        return i18n("%1 days ago", Math.round(days))
    }

    return i18n("long ago")
}

function schedumainleDataReload() {
    var now = new Date().getTime()
    loadingError = true
    return now + 600000
}

function getReloadedAgoMs(lastReloaded) {
    if (!lastReloaded) {
        lastReloaded = 0
    }
    return new Date().getTime() - lastReloaded
}

function getPlasmoidStatus(lastReloaded, inTrayActiveTimeoutSec) {
//    dbgprint2("getPlasmoidStatus")
//    dbgprint("lastReloaded=" + lastReloaded)
//    dbgprint("inTrayActiveTimeoutSec=" + inTrayActiveTimeoutSec)
    var reloadedAgoMs = getReloadedAgoMs(lastReloaded)
//    dbgprint("reloadedAgoMs=" + reloadedAgoMs)
    if (reloadedAgoMs < inTrayActiveTimeoutSec * 1000) {
        return PlasmaCore.Types.ActiveStatus
    } else {
        return PlasmaCore.Types.PassiveStatus
    }
}

function generateCacheKey(placeIdentifier) {
    return 'cache_' + Qt.md5(placeIdentifier)
}

function isXmlStringValid(xmlString) {
    return xmlString.indexOf('<?xml ') === 0 || xmlString.indexOf('<weatherdata>') === 0 || xmlString.indexOf('<current>') === 0
}

function fetchXmlFromInternet(getUrl, successCallback, failureCallback) {
    var xhr = new XMLHttpRequest()
    xhr.onreadystatechange = function () {
        if (xhr.readyState !== XMLHttpRequest.DONE) {
//            dbgprint(xhr.readyState)
            return
        }

        if (xhr.status !== 200) {
//            dbgprint('ERROR - status: ' + xhr.status)
//            dbgprint('ERROR - responseText: ' + xhr.responseText)
            failureCallback()
            return
        }

        // success
//        dbgprint('successfully loaded from the internet')
//        dbgprint('successfully of url-call: ' + getUrl)
//        dbgprint('responseText: ' + xhr.responseText)

        var xmlString = xhr.responseText
        if (!DataLoader.isXmlStringValid(xmlString)) {
//            dbgprint('incoming xmlString is not valid: ' + xmlString)
            return
        }
//        dbgprint('incoming text seems to be valid')

        successCallback(xmlString)
    }
//    dbgprint('GET url opening: ' + getUrl)
    xhr.open('GET', getUrl)
//    dbgprint('GET url sending: ' + getUrl)
    xhr.send()

//    dbgprint('GET called for url: ' + getUrl)
    return xhr
}

function fetchJsonFromInternet(getUrl, successCallback, failureCallback) {

    var xhr = new XMLHttpRequest()

    // Leer el updateInterval de la configuración (convertir minutos a milisegundos)
    var timeoutMinutes = plasmoid.configuration.updateInterval || 30
    xhr.timeout = timeoutMinutes * 60 * 1000  // minutos a milisegundos

    xhr.open('GET', getUrl)
    xhr.setRequestHeader("User-Agent","Mozilla/5.0 (X11; Linux x86_64) Gecko/20100101 ")

    xhr.send()

    xhr.ontimeout = () => {
//        console.log("fetchJsonFromInternet: timeout after", timeoutMinutes, "minutes")
        failureCallback()
    }

    xhr.onerror = (event) => {
//        console.log("fetchJsonFromInternet: error", event)
        failureCallback()
    }

    xhr.onload = () => {
//        console.log("Response status:", xhr.status)
//        console.log("Response length:", xhr.responseText.length)

        var jsonString = xhr.responseText
        if (!DataLoader.isJsonString(jsonString)) {
//            console.log("Invalid JSON, status:", xhr.status)
//            console.log("Response preview:", jsonString.substring(0, 200))
            failureCallback()
            return
        }
        successCallback(jsonString)
    }

    return xhr
}

function isJsonString(str) {
    if (!str || str === "") return false
        // Elimina espacios en blanco al inicio
        str = str.trim()
        if (str === "") return false

            try {
                var parsed = JSON.parse(str)
                // Acepta cualquier objeto o array válido
                return (typeof parsed === 'object' && parsed !== null)
            } catch (e) {
//                console.log("JSON parse error:", e.message)
//                console.log("First 100 chars:", str.substring(0, 100))
                return false
            }
}
