const express = require('express')
const app = express();
require('dotenv').config()
const bodyParser = require('body-parser');
const routes = require('./routes');

const PORT = 5000

app.use(bodyParser.json());

app.use('/', routes);

app.get('/', (req, res) => res.send('ping'))

app.listen(PORT, () => {
    console.log(`CaptionGeneratorAPI listening on port ${PORT}!`)
})