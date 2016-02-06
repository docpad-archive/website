var request = require('superagent');
var assert = require('assert-helpers');

var HTTP_OK = 200;

function initialiseTests() {
    var url = "http://127.0.0.1:9778/";
    request.get(url).end(function (error, res) {
       assert.equal(res.statusCode, HTTP_OK, 'status code');
       require("./tests/pages-exist.js");
    });

}

initialiseTests();