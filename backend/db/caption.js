const db = require('../db')

const getCaption = async () => {
    results = await db.query('SELECT * FROM test');
    const captions = results.rows;
    // do some logic (?)
    return captions;
}

module.exports = { getCaption };