"use strict"
var cheerio = require('cheerio');

function buildLinkList(html, selector) {
    var output = [];
    try {
        var $ = cheerio.load(html);
        var items = $(selector);
        items.each(function () {
            var rel = $(this).attr('rel');
            if (rel !== 'nofollow') {
                var href = $(this).attr('href');
                if (href) {
                    if (href.indexOf('#') === -1) {
                        output.push(href);
                    }
                }
            }

        });
        return output;
    } catch (err) {
        console.log(err);
        throw err;
    }
}

module.exports.buildLinkList = buildLinkList;