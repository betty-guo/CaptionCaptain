const db = require('../db');
var http = require("http");

const tblNameCaptions = 'captions';
const tblNameKeywords = 'keywords';
const tblNameSynonyms = 'associatedwords';


const getCaption = async (words) => {
    // translate js array to sql
    var sqlWhereStmtEnd = words.map((x) => {return '\'%' +x + '%\''}).join(' or keyword like ');
    console.log(sqlWhereStmtEnd);

    // keyword | caption
    // ------------------------------------
    // face    | woke up like this
    // sunset  | look at the nice view!
    // ...

    // 1: first try to find rows with keywords in words given
    const queryStr = 'SELECT * FROM ' + tblNameCaptions + ' WHERE keyword like ' + sqlWhereStmtEnd + ';';
    console.log(queryStr);
    results = await db.query(queryStr);
    console.log(results);
    //results = await db.query('SELECT * FROM ' + tblName + ';');
    if (results.rowCount > 0) {  // if there were rows with those keywords
        return '{ "caption" : "' + results.rows[0].quote + '"}';
    }
    // 2: synonymSearch
    const queryStrSynonyms = 'SELECT * FROM ' + tblNameSynonyms + ' WHERE word like ' + sqlWhereStmtEnd + ';';
    console.log(queryStrSynonyms);
    results = await db.query(queryStrSynonyms);
    console.log(results);

    if (results.rowCount > 0) {  // if there were rows with those associated words
        const queryStr2 = 'SELECT * FROM ' + tblNameCaptions + ' WHERE keyword like \'%' + results.rows[0].keyword + '%\';';
        console.log(queryStr2);
        results2 = await db.query(queryStr2);
        console.log(results2);
        if (results2.rowCount > 0) {
            return '{ "caption" : "' + results2.rows[0].quote + '"}'
        }
        
    }

    // default
    return '{ "caption" : "Say Cheese!"}'
}

module.exports = { getCaption };