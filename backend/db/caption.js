const db = require('../db');
var http = require("http");

const tblName = 'captions';

const getCaption = async (words) => {
    // translate js array to sql
    var sqlWordsArr = '(\'' + words.join('\',\'') + '\')';
    console.log(sqlWordsArr);

    // keyword | caption
    // ------------------------------------
    // face    | woke up like this
    // sunset  | look at the nice view!
    // ...

    // 1: first try to find rows with keywords in words given
    results = await db.query('SELECT * FROM ' + tblName + ' WHERE keyword in ' + sqlWordsArr + ';');
    //results = await db.query('SELECT * FROM ' + tblName + ';');
    if (results != null) {  // if there were rows with those keywords
        return results.rows[0].quote;
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
    // 3: synonymSearch
    
    return "Empty";
}

module.exports = { getCaption };