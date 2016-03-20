/*global require*/
"use strict";
var checkURL = require('./check-url').checkURL;
var buildLinkList = require('./link-builder').buildLinkList;
var assert = require("./assert-helpers");
var cheerio = require('cheerio');
var urlUtil = require('url');


function testLinks(config) {

    if (!config || !config.joe) {
        throw new Error("Must supply config option to testMenu with joe property");
    }
    var joe = config.joe;
    var pageURL = config.pageURL;
    var title = config.title || "Test page links for";
    var linkSelector = config.linkSelector || 'a';
    var siteURL = config.siteURL;
    joe.suite(title+ " "+pageURL, function (suite, test) {
        this.setNestedConfig({
            onError: 'ignore'
        });

        var linkList = [];
        test(pageURL, function (complete) {
            var fullUrl = urlUtil.resolve(siteURL,pageURL);
            checkURL(fullUrl, function (error, statusCode, res) {
                assert.equal(statusCode, 200, "status code");
                linkList = buildLinkList(res.text, linkSelector);
                complete();
            });
        });

        suite(title+" "+pageURL, function (suite, test) {
            this.setNestedConfig({
                onError: 'ignore'
            });

            linkList.forEach(function (url) {
                if(url[0] === "/"){
                    url = urlUtil.resolve(siteURL,url);
                }
                test(url, function (complete) {
                    checkURL(url, function (error, statusCode) {
                        assert.equal(statusCode, 200, "status code");
                        complete();
                    });

                });

            });

        });


    });

}

module.exports.testLinks = testLinks;