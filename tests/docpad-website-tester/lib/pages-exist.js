/*global require*/
"use strict"

// Import
var util = require("util");
var joe = require("joe");
var assert = require("./assert-helpers"); //needed to override the logComparison method
var cheerio = require('cheerio');
var urlUtil = require('url');
var checkURL = require('./check-url').checkURL;
var buildLinkList = require('./link-builder').buildLinkList;
var testMenu = require('./menu-tester').testMenu;
var testLinks = require('./link-tester').testLinks;

var Reporter = require('joe-reporter-compact');
var compact = new Reporter();
joe.setReporter(compact);


// Prepare
var HTTP_NOT_FOUND = 404;
var HTTP_OK = 200;
var HTTP_BAD_REQUEST = 400;


function pagesExist(opts,server) {

	var siteURL = opts.siteURL || "http://127.0.0.1:9778/";
	var DocPadOrHttpServer = server;
	var menuSelector = opts.menuSelector || "#nav-menu";
	var menuItemSelector = opts.menuItemSelector || "#nav-menu li.menu-item a";
	var homeTitleSelector = opts.homeTitleSelector || "#brand h1";
	var pageTitleSelector = opts.pageTitleSelector || ".page-title h1"
	var homeTitleText = opts.homeTitleText || "DocPad";
	var expectedMenus = opts.expectedMenus;
	var pageLinkSelector = opts.pageLinkSelector || "main a";


	joe.suite("Home Page Tests", function (suite, test) {

		test("Home page exists", function (complete) {
			checkURL(siteURL, function (error, statusCode, res) {
				assert.equal(statusCode, HTTP_OK, "status code");
				complete();
			});
		});

		//should really always check the content of the page
		//in someway as links and urls can sometimes lead to
		//the wrong page
		test("Home page Title is: 'DocPad", function (complete) {
			var url = siteURL;
			checkURL(url, function (error, statusCode, res) {
				var $ = cheerio.load(res.text);
				var title = $(homeTitleSelector).text().trim();
				assert.equal(title, homeTitleText, 'Title is '+homeTitleText);
				complete();
			});
		});

		test("Home page has navigation menu", function (complete) {
			var url = siteURL;
			checkURL(url, function (error, statusCode, res) {
				var $ = cheerio.load(res.text);
				var menu = $('#nav-menu');
				assert.equal(1, menu.length);
				buildLinkList(res.text, menuItemSelector);
				complete();
			});
		});
	});



	
	testMenu({
		joe: joe,
		expectedMenus: expectedMenus,
		siteURL: siteURL,
		menuItemSelector: menuItemSelector,
		titleSelector: pageTitleSelector
	});


	expectedMenus.forEach(function (item) {
		testLinks({
			joe: joe,
			siteURL: siteURL,
			pageURL: item.link,
			linkSelector: pageLinkSelector,
			title: ''
		});
	});

	joe.suite("Shut Down..", function (suite, test) {
		//joe.exit();
		if (DocPadOrHttpServer) {
			if (DocPadOrHttpServer.close) {
				DocPadOrHttpServer.close();
			} else if (DocPadOrHttpServer.kill) {
				DocPadOrHttpServer.kill();
			} else {
				console.log("NO kill method or close method");
			}

		} else {
			console.log("NO DocPad or HttpServer");
		} 
	});
}

module.exports.pagesExist = pagesExist;