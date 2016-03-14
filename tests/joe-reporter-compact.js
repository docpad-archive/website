/*global process, module, require, window*/
"use strict";
var util = require('util');
var ConsoleReporter = require('joe-reporter-console');

var isBrowser = (typeof window === 'undefined') ? false : true;
var isWindows = process ? process.platform.indexOf('win') > -1 : false;
var cliColor = null;
if (!isBrowser) {
    try {
        cliColor = require('cli-color');
    } catch (err) {}
}



function CompactReporter(config) {
    
    CompactReporter.super_.call(this, config);
    this.tty = ((process.stdout && process.stdout.isTTY === true) && (process.stderr && process.stderr.isTTY === true)) || false;
    this.useColors = (process ? process.argv.indexOf('--no-colors') > -1 : false) ? (cliColor === null) : true;
    this.actual = "Comparison Actual ";
    this.expected = "Comparison Expected ";
    this.indent = '    ';

}

util.inherits(CompactReporter, ConsoleReporter);

CompactReporter.prototype.startTest = function () {};

CompactReporter.prototype.finishSuite = function (suite, err) {
    var name = this.getItemName(suite);
    if (!name) {
        return;
    }
    var check = err ? this.config.fail : this.config.pass;
    var message = name + check;
    console.log(message);
    console.log("-----------------------------"+"\n");
};

CompactReporter.prototype.color = function (value, color) {
    if (this.useColors) {
        if (color && cliColor) {
            value = cliColor[color](value);
        }
    }
    return value;
};



CompactReporter.prototype.finishTest = function (test, err) {
    var name = test.getConfig().name;
    if (!name) {
        return;
    }

    var check = err ? this.config.fail : this.config.pass;

    var message = this.indent+name + check;
    console.log(message);
    if (err && err.actual) {
        var actual = this.color(err.actual, "yellow");
        var expected = this.color(err.expected, "yellow");
        console.log(this.indent+this.indent+this.actual, actual);
        console.log(this.indent+this.indent+this.expected, expected);
    }

};

CompactReporter.prototype.exit = function (exitCode) {
    var totals = this.joe.getTotals();
    var totalTests = totals.totalTests;
    var totalPassedTests = totals.totalPassedTests;
    var totalFailedTests = totals.totalFailedTests;
    var totalIncompleteTests = totals.totalIncompleteTests;
    var totalErrors = totals.totalErrors;

    if (exitCode) {
        var errorLogs = this.joe.getErrorLogs();
        console.log(this.config.summaryFail, totalPassedTests, totalTests, totalFailedTests, totalIncompleteTests, totalErrors);
        console.log("-----------------------------");
        console.log(this.color("Error summary:","redBright"));
        var lastSuit = "";
        for (var i = 0; i < errorLogs.length; i++) {
            var errorLog = errorLogs[i];
            var test = errorLog.test;
            var suite = test.getConfig().parent.getConfig().name;
            if(suite !== lastSuit){
                console.log("Suite: ",suite);
                lastSuit = suite;
            }
            
            console.log(this.indent, i + 1+": ",test.getConfig().name);
        }

        console.log("-----------------------------");
    } else {
        console.log("\n" + this.config.summaryPass, totalPassedTests, totalTests);
    }
};

module.exports = CompactReporter;