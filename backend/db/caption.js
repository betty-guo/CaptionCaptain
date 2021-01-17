const db = require('../db');
const util = require('./util')

const tblNameCaptions = 'captions';
const tblNameKeywords = 'keywords';
const tblNameSynonyms = 'associatedwords';

// keyword | caption
// ------------------------------------
// face    | woke up like this
// sunset  | look at the nice view!
// ...

const keyWordsSearch = async (words) => {
    const sqlWhereStmtEnd = words.map((x) => { return '\'' + x + '%\'' }).join(' or keyword like ');
    const queryStrBasic = 'SELECT * FROM ' + tblNameCaptions + ' WHERE keyword like ' + sqlWhereStmtEnd + ';';
    // console.log(queryStrBasic);
    const results = await db.query(queryStrBasic);
    var rowCount = results.rowCount;
    if (rowCount > 0) {  // if there were rows with those keywords
        // console.log("quote: " + results.rows[util.getRandIdx(rowCount)].quote);
        return results.rows[util.getRandIdx(rowCount)].quote;
    } else {
        return null;
    }
}

const synonymSearch = async (words) => {
    const sqlWhereStmtEnd = words.map((x) => { return '\'' + x + '%\'' }).join(' or keyword like ');
    const queryStrSynonyms = 'SELECT * FROM ' + tblNameSynonyms + ' WHERE word like ' + sqlWhereStmtEnd + ';';
    // console.log(queryStrSynonyms);
    const results = await db.query(queryStrSynonyms);

    if (results.rowCount > 0) {  // if there were rows with those associated words
        const queryStr2 = 'SELECT * FROM ' + tblNameCaptions + ' WHERE keyword like \'%' + results.rows[0].keyword + '%\';';
        // console.log(queryStr2);
        results2 = await db.query(queryStr2);
        rowCount = results2.rowCount
        if (rowCount > 0) {
            return results2.rows[util.getRandIdx(rowCount)].quote;
        }
    }
    return null;
}

const revDictSearch = async (words) => {
    const reverseDictSite = "https://api.datamuse.com/words?ml=";
    const wordsOnUrl = words.join("+");

    var revDictResStr = await util.doRequest(reverseDictSite + wordsOnUrl);
    const revDictRes = JSON.parse(revDictResStr);
    const topWordsStrArr = revDictRes.slice(0, 5).map((wordObj) => { return wordObj.word });
    // console.log(topWordsStrArr);
    const keyWordsSearchRes = keyWordsSearch(topWordsStrArr);
    if (keyWordsSearchRes) { return keyWordsSearchRes; }
    const synonymSearchRes = synonymSearch(topWordsStrArr);
    if (synonymSearchRes) { return synonymSearchRes; }
}

const searchAlgo = async (words) => {
    const sqlWhereStmtEnd = words.map((x) => { return '\'% ' + x + ' %\'' }).join(' or quote like ');
    const queryStrBasicSearch = 'SELECT * FROM ' + tblNameCaptions + ' WHERE quote like ' + sqlWhereStmtEnd + ';';

    const results = await db.query(queryStrBasicSearch);
    console.log(results);
    if (results.rowCount > 0) {  // if there were rows with those associated words
        var scoredResults = results.rows.map((wordObj) => {
            var tempRow = wordObj;
            tempRow.score = 0.0;
            const quoteArr = tempRow.quote.split(" ");
            quoteArr.forEach(wordInQuote => {
                words.forEach(wordInSearch => {
                    const word1 = wordInSearch.toLower().replace(/[(?:\r\n|\r|\n|\t), ]/g, '');
                    const word2 = wordInQuote.toLower().replace(/[(?:\r\n|\r|\n|\t), ]/g, '');
                    console.log(word1 + " " + word1)
                    if(word1 == word2) {
                        tempRow.score += (1 / words.length);
                    }
                });
            });
            return tempRow;
        });
        scoredResults.sort(util.compareQuoteObj);
        console.log(scoredResults);
        var rowCount = 5; // get from the top five rows
        if (scoredResults.rowCount < rowCount) { rowCount = scoredResults.rowCount; }
        return scoredResults.slice(0, rowCount)[util.getRandIdx(rowCount/2)].quote;
    }
}

const getCaption = async (words) => {
    // translate js array to sql
    
    // 1: first try to find rows with keywords in words given
    const keyWordsSearchRes = await keyWordsSearch(words);
    if (keyWordsSearchRes !== null) {
        // console.log("got here..." + keyWordsSearchRes)
        return keyWordsSearchRes;
    }

    // 2: synonymSearch
    const synonymSearchRes = await synonymSearch(words);
    if (synonymSearchRes) { return synonymSearchRes; }

    // 3: do a reverse dictionary aggregation of all the words, then try that:
    const revDictSearchRes = await revDictSearch(words);
    if (revDictSearchRes) { return revDictSearchRes; }
    
    // default... a search algo on all quotes
    const searchAlgoRes = await searchAlgo(words.slice(0, 5));
    if (searchAlgoRes) { return searchAlgoRes; }

    return "Say cheese~";
}

module.exports = { getCaption };