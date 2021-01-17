// const Math = require("Math");
const request = require('request');

function getRandIdx(arrLen) {
  return Math.floor(Math.random() * arrLen);
}

function doRequest(url) {
  return new Promise(function (resolve, reject) {
      request(url, function (error, res, body) {
          if (!error && res.statusCode == 200) {
              resolve(body);
          } else {
              console.log(error);
              reject(error);
          }
      });
  });
}

module.exports = { getRandIdx, doRequest }
