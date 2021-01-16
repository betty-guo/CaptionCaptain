const express = require('express')
const app = express();
require('dotenv').config()
const bodyParser = require('body-parser');
const routes = require('./routes');

const PORT = 8080

app.use(bodyParser.json());

app.use('/', routes);

app.get('/', (req, res) => res.send('ping'));

/*
curl --header "Content-Type: application/json" \
  --request GET \
  --data '{"words":["love"]}' \
  http://localhost:8080/caption
  */

app.listen(PORT, () => {
    console.log(`CaptionGeneratorAPI listening on port ${PORT}!`)
})