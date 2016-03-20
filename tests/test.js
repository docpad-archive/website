/*global require, process*/
"use strict"

var tester = require('./docpad-website-tester');
var expectedMenus = require('./menus.json');

tester.runTests({
	host: "127.0.0.1",
	port: "9778",
	menuSelector: "#nav-menu",
	menuItemSelector: "#nav-menu li.menu-item a",
	homeTitleSelector: "#brand h1",
	pageTitleSelector: ".page-title h1",
	homeTitleText: "DocPad",
	expectedMenus: expectedMenus,
	pageLinkSelector: "main a"
});