/*global require, process*/
"use strict"

var assert = require('assert-helpers');
var request = require('superagent');
var httpServer = require('http-server');
var pagesEx = require("./lib/pages-exist");
var startServer = require("./lib/start-server");

var HTTP_OK = 200;
var ip;
var port;
var siteUrl;
var options;

function initialiseTests(server) {
	request.get(siteUrl).end(function (error, res) {
		assert.equal(res.statusCode, HTTP_OK, 'status code');
		pagesEx.pagesExist(options, server);
	});
}

function runTests(opts) {
	try {
		options = opts || {};
		ip = options.host || '127.0.0.1';
		port = options.port || '9778';
		siteUrl = "http://" + ip + ":" + port;
		request.get(siteUrl).end(function (error, res) {
			if (res && res.statusCode === HTTP_OK) {
				console.log("Server is already running on " + siteUrl);
				//if the server is already running then we have no need
				//to pass a server object to initializeTests as we don't
				//need to shut it down
				initialiseTests();
			} else {
				startServer.start({
					ip: ip,
					port: port
				}, initialiseTests)
			}
		});
	} catch (err) {
		console.log(err);
		throw err;
	}
}

module.exports.runTests = runTests;