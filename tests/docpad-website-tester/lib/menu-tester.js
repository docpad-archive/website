/*global require*/
"use strict";
var checkURL = require('./check-url').checkURL;
var buildLinkList = require('./link-builder').buildLinkList;
var assert = require("./assert-helpers");
var cheerio = require('cheerio');
var urlUtil = require('url');


function testMenu(config) {

    if (!config || !config.joe) {
        throw new Error("Must supply config option to testMenu with joe property");
    }
    var joe = config.joe;
    var menuItemSelector = config.menuItemSelector || '#nav-menu li.menu-item a';
    var expectedMenus = config.expectedMenus;
    var siteURL = config.siteURL;
    var title = config.title || "Menu Links Work";
    var titleSelector = config.titleSelector || 'h1';
    joe.suite(title, function (suite, test) {
        this.setNestedConfig({
            onError: 'ignore'
        });

        var linkList = [];
        test(title, function (complete) {
            checkURL(siteURL, function (error, statusCode, res) {
                linkList = buildLinkList(res.text, menuItemSelector);
                assert.equal(linkList.length, expectedMenus.length, 'Number of menu items is: ' + expectedMenus.length);
                complete();
            });
        });

        suite("Test All Menu Links", function (suite, test) {
            this.setNestedConfig({
                onError: 'ignore'
            });
            expectedMenus.forEach(function (item) {
                var fullUrl = urlUtil.resolve(siteURL, item.link);
                var html = "";
                test(fullUrl, function (complete) {
                    checkURL(fullUrl, function (error, statusCode, response) {
                        assert.equal(statusCode, 200, "status code");
                        html = response.text;
                        complete();
                    });

                });

                test("Page has heading: '" + item.title + "'", function (complete) {
                    var $ = cheerio.load(html);
                    var heading = $(titleSelector).text(item.title);
                    assert.equal(heading.length, 1, "Page has heading: '" + item.title + "'");
                    complete();
                });
            });

        });


    });

}

module.exports.testMenu = testMenu;