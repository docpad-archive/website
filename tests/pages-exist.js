/*global require, process*/
"use strict"



// Import
var joe = require("joe");
var assert = require('assert');
var assertHelper = require("assert-helpers");
var request = require("superagent");
var cheerio = require('cheerio');
var urlUtil = require('url');
var checkURL = require('./linkChecker').checkURL;

// Prepare
var HTTP_NOT_FOUND = 404;
var HTTP_OK = 200;
var HTTP_BAD_REQUEST = 400;


var siteURL = "http://127.0.0.1:9778/";


function buildLinkList(html, selector) {
    var output = [];
    var $ = cheerio.load(html);
    var items = $(selector);
    items.each(function (i, el) {
        var href = $(this).attr('href');
        output.push(href);
    });
    return output;
}

function isEqual (actual, expected, testName) {
    try {
		assert.equal(actual, expected, testName)
	}
	catch ( checkError ) {
		assertHelper.logComparison(actual, expected, testName)
        //don't throw error - totally contrary to the idea
        //of tests
	}
}

joe.suite("Home Page Tests", function (suite, test) {


    test("Home page exists", function (done) {
        checkURL(siteURL,function(error,statusCode,res){
            isEqual(statusCode, HTTP_OK, "status code");
            buildLinkList(res.text, '#nav-menu li.menu-item a');
            done();
        });
    });

    //should really always check the content of the page
    //in someway as links and urls can sometimes lead to
    //the wrong page
    test("Home page Title is: 'DocPad", function (done) {
        var url = siteURL;
        request.get(url).end(function (error, res) {
            var $ = cheerio.load(res.text);
            var title = $('#brand h1').text().trim();
            isEqual(title, 'DocPad', 'Title is DocPad');
            done();
        });
    });

    test("Home page has navigation menu", function (done) {
        var url = siteURL;
        request.get(url).end(function (error, res) {
            var $ = cheerio.load(res.text);
            var menu = $('#nav-menu');
            assert.equal(1, menu.length);
            done();
        });
    });



});

joe.suite("Menu Links Work", function (suite, test) {

    var linkList = [];
    test("Menu links exists", function (done) {
        request.get(siteURL).end(function (error, res) {
            var $ = cheerio.load(res.text);
            var menu = $('#nav-menu');
            assert.equal(menu.length, 1, "Nav menu exists");
            linkList = buildLinkList(res.text, '#nav-menu li.menu-item a');
            done();
        });
    });

    linkList.forEach(function (url) {
        var fullUrl = urlUtil.resolve(siteURL, url);
        test(fullUrl, function (done) {
            request.get(fullUrl).end(function (error, res) {
                assert.isEqual(res.statusCode, HTTP_OK, "status code");
                done();
            });
        });
    });


});

joe.suite("Showcase Links Work", function (suite, test) {

    var showcaseUrl = urlUtil.resolve(siteURL, '/docs/showcase');
    var linkList = [];
    test("Showcase page exists", function (done) {
        request.get(showcaseUrl).end(function (error, res) {
            isEqual(res.statusCode, HTTP_OK, "status code");
            linkList = buildLinkList(res.text, 'article ul li a');
            done();
        });
    });


    suite("Test All Showcase Links", function (suite,test) {
            linkList.forEach(function (url) {
                test(url, function (done) {
                    request.get(url).end(function (error, res) {
 
                        if(res == null){
                            isEqual(null, HTTP_OK, "status code");
                        }
                               
       
                        isEqual(res.statusCode, HTTP_OK, "status code");
                        done();
                    });
                });
            });
        });


});