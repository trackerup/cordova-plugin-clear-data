
var ClearData = {
    cache : function( success, error ) {
        cordova.exec(success, error, "ClearData", "cache", [])
    }
};

module.exports = ClearData;
