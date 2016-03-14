/*global require, process*/
"use strict"



// Import
var joe = require("joe");
//var assert = require("assert-helpers");
var chai = require('chai');
var assert = chai.assert;
var cheerio = require('cheerio');
var urlUtil = require('url');
var checkURL = require('./linkChecker').checkURL;

var Reporter = require('./joe-reporter-compact');
var compact = new Reporter();
joe.setReporter(compact);

assert.logComparison = function(){};

// Prepare
var HTTP_NOT_FOUND = 404;
var HTTP_OK = 200;
var HTTP_BAD_REQUEST = 400;


var siteURL = "http://127.0.0.1:9778/";


function buildLinkList(html, selector) {
    var output = [];
    var $ = cheerio.load(html);
    var items = $(selector);
    items.each(function () {
        var href = $(this).attr('href');
        output.push(href);
    });
    return output;
}


joe.suite("Home Page Tests", function (suite, test) {


    test("Home page exists", function () {
        checkURL(siteURL, function (error, statusCode, res) {
            assert.equal(statusCode, HTTP_OK, "status code");
            buildLinkList(res.text, '#nav-menu li.menu-item a');
        });
    });

    //should really always check the content of the page
    //in someway as links and urls can sometimes lead to
    //the wrong page
    test("Home page Title is: 'DocPad", function () {
        var url = siteURL;
        checkURL(url, function (error, statusCode, res) {
            var $ = cheerio.load(res.text);
            var title = $('#brand h1').text().trim();
            assert.equal(title, 'DocPad', 'Title is DocPad');
        });
    });

    test("Home page has navigation menu", function () {
        var url = siteURL;
        checkURL(url, function (error, statusCode, res) {
            var $ = cheerio.load(res.text);
            var menu = $('#nav-menu');
            assert.equal(1, menu.length);
        });
    });



});

joe.suite("Menu Links Work", function (suite, test) {
    this.setNestedConfig({
        onError: 'ignore'
    });

    var linkList = [];
    test("Menu links exists", function () {
        checkURL(siteURL, function (error, statusCode, res) {
            var $ = cheerio.load(res.text);
            var menu = $('#nav-menu');
            assert.equal(menu.length, 1, "Nav menu exists");
            linkList = buildLinkList(res.text, '#nav-menu li.menu-item a');
        });
    });

    suite("Test All Menu Links", function (suite, test) {
        this.setNestedConfig({
            onError: 'ignore'
        });
        linkList.forEach(function (url) {
            var fullUrl = urlUtil.resolve(siteURL, url);
            test(fullUrl, function () {
                checkURL(fullUrl, function (error, statusCode) {
                    assert.isEqual(statusCode, HTTP_OK, "status code");
                });
            });
        });

    });


});

joe.suite("Showcase Links Work", function (suite, test) {
    this.setNestedConfig({
        onError: 'ignore'
    });
    var showcaseUrl = urlUtil.resolve(siteURL, '/docs/showcase');
    var linkList = [];
    test("Showcase page exists", function (complete) {
        checkURL(showcaseUrl, function (error, statusCode, res) {
            assert.equal(res.statusCode, HTTP_OK, "status code");
            linkList = buildLinkList(res.text, 'article ul li a');
            complete();
        });
    });

    suite("Test All Showcase Links", function (suite, test) {
        this.setNestedConfig({
            onError: 'ignore'
        });
        linkList.forEach(function (url) {
            test(url, function (complete) {
                checkURL(url, function (error, statusCode) {
                    assert.equal(statusCode, HTTP_OK, "status code");
                    complete();
                });
            });
        });
    });

});