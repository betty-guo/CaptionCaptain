const { Pool } = require('pg')
const pool = new Pool()

const query = (text, params) => {
  return pool.query(text, params)
}

module.exports = { query }