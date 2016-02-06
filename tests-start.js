/*global require, process*/
var fs = require('fs');
var util = require('util');

var joe = require('joe');
var assert = require('assert-helpers');
var request = require('superagent');

var HTTP_NOT_FOUND = 404;
var HTTP_OK = 200;
var HTTP_BAD_REQUEST = 400;

function initialiseTests() {
    var url = "http://127.0.0.1:9778/";
    request.get(url).end(function (error, res) {
       assert.equal(res.statusCode, HTTP_OK, 'status code');
       require("./tests/pages-exist.js");
    });

}

function runTests() {
    "use strict";

    var path = require('path');
    var spawn = require('child_process').spawn;

    var APP_PATH = process.cwd();
    var MODULES_PATH = path.join(APP_PATH, "node_modules");
    var DOCPAD = path.join(MODULES_PATH, "docpad/bin/docpad");

    var child = spawn('node', [DOCPAD, 'server'], {
        output: true,
        cwd: APP_PATH
    });

    child.stdout.on('data', function (chunk) {
        var str = chunk.toString();
        console.log(str);
        if (str.indexOf("The action completed successfully") > -1) {
            console.log("!!!DOCPAD IS READY...");
            initialiseTests();
        }

    });



}

runTests();