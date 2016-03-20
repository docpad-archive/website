/*global require, process*/
"use strict"

try {
	var assert = require('assert-helpers');
	var request = require('superagent');
	var httpServer = require('http-server');
	var pagesEx = require("./pages-exist");
	var startServer = require("./start-server");
} catch (err) {
	console.log(err);
	throw err;
}

var HTTP_OK = 200;

var ip = '127.0.0.1';
var port = '9778';
var siteUrl = "http://" + ip + ":" + port;

function initialiseTests(server) {

	request.get(siteUrl).end(function (error, res) {
		assert.equal(res.statusCode, HTTP_OK, 'status code');
		pagesEx.pagesExist(siteUrl, server);

	});

}


function runTests() {

	request.get(siteUrl).end(function (error, res) {
		if (res && res.statusCode === HTTP_OK) {
			console.log("!!!SERVER ALREADY RUNNING ON " + siteUrl);
			initialiseTests();
		} else {
			startServer.start({
				ip: ip,
				port: port
			}, initialiseTests)
		}

	});

}

runTests();