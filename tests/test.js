/*global require, process*/
"use strict"

var assert = require('assert-helpers');
var request = require('superagent');

var HTTP_OK = 200;

var siteUrl = "http://127.0.0.1:9778/";

function initialiseTests() {

    request.get(siteUrl).end(function (error, res) {
        assert.equal(res.statusCode, HTTP_OK, 'status code');
        require("./pages-exist.js");
    });

}

function startDocPad() {

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
        var str = chunk.toString().trim();
        console.log(str);
        if (str.indexOf("The action completed successfully") > -1) {
            console.log("!!!DOCPAD IS READY...");
            initialiseTests();
        }

    });
}

function runTests() {
    
    request.get(siteUrl).end(function (error, res) {
        if(res && res.statusCode === HTTP_OK){
           console.log("!!!DOCPAD ALREADY RUNNING...");
           initialiseTests(); 
        }else {
            startDocPad();
        }

    });

}

runTests();