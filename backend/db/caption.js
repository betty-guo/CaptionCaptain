const db = require('../db');
var http = require("http");

const tblName = 'captions';

const getCaption = async (words) => {
    // translate js array to sql
    var sqlWordsArr = '(' + words.join(',') + ')';

    // keyword | caption
    // ------------------------------------
    // face    | woke up like this
    // sunset  | look at the nice view!
    // ...

    // 1: first try to find rows with keywords in words given
    results = await db.query('SELECT * FROM ' + tblName + ' WHERE keyword in ' + sqlWordsArr + ';');

    if (results != null) {  // if there were rows with those keywords
        return
    } else {
        // 2: query https://api.datamuse.com/words?ml=nose+ear+eyes+mouth+... and try to find rows with keywords from that output
        var options = {
            host: "https://api.datamuse.com",
            port: 80,
            path: '/words?ml=' + words.join('+'),
            method: 'GET'
        }
        // synonomSearch = await http.request
    }
    // 3: ...?
    // results = await db.query('SELECT * FROM ' + tblName + ' WHERE keyword in ' + 'asd');
    const captions = results.rows;
    for (let i = 0; i < captions.length; i++){
        captions[i].keyword = 0;
    }
    // do some logic (?)
    
    return captions[0];
}

module.exports = { getCaption };