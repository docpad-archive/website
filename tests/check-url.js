/*global require, process*/
"use strict"
process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = '0';

var request = require("superagent");

function checkURL(url,done) {
    request.get(url).end(function (error, res) {
        var statusCode = (res) ? res.statusCode : null;
        done(error,statusCode,res)
    });

}

module.exports.checkURL = checkURL;