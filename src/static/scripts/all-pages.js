/*global $, Fluidvids*/
$(function () {
	"use strict";

	var body = $('body');
	/* Determine viewport width matching with media queries */
	function viewport() {

		var e = window,
			a = 'inner';

		if (!('innerWidth' in window)) {

			a = 'client';
			e = document.documentElement || document.body;

		}

		return {
			width: e[a + 'Width'],
			height: e[a + 'Height']
		};
	}

	/* Toggle "mobile" class */
	function mobileClass() {
		var vpWidth = viewport().width; // This should match media queries
		if ((vpWidth <= 768) && (!body.hasClass('mobile'))) {
			body.addClass('mobile');
		} else if ((vpWidth > 768) && (body.hasClass('mobile'))) {
			body.removeClass('mobile');
		}
	}

	mobileClass();
	$(window).resize(mobileClass);

	/* Smooth scroll */
	function smoothScroll() {
		$('a[href*=#]:not([href=#])').click(function () {
			if (location.pathname.replace(/^\//, '') === this.pathname.replace(/^\//, '') || location.hostname === this.hostname) {
				var target = $(this.hash);
				target = target.length ? target : $('[name=' + this.hash.slice(1) + ']');
				if (target.length) {

					$('html,body').animate({
						scrollTop: target.offset().top
					}, 500);
					return false;
				}
			}
		});
	}

	smoothScroll();

	/* Fixed header if there's no Big slider */
	if (!$('#intro-wrap').length) {
		$('header').addClass('fixed-header');
	}

	/* Submenus */
	var menuToggle = $('#menu-toggle');
	var headerNav = $('nav');
	var headerNavUl = headerNav.children('ul');
	var liWithSub = headerNavUl.children('li:has(ul.sub-menu)');
	var ulSub = $('ul.sub-menu');
	var parent = ulSub.children('li:has(ul.sub-menu)').children('a');
	var menuArrow = '<span class="sub-arrow"><i class="fa fa-chevron-down"></i></span>';

	liWithSub.addClass('parent').children('a').append(menuArrow);
	parent.addClass('parent');

	menuToggle.click(function () {
		headerNavUl.slideToggle(200);
		$(this).children('i').toggleClass('active');
		return false;
	});

	$(window).resize(function () {
		if (!body.hasClass('mobile')) {
			headerNavUl.removeAttr('style');
			menuToggle.children('i').removeClass('active');
		}
	});

	/* Make page's odd sections darker */
	var page = $('.page');
	var pageSections = page.find('.section');
	var oddSections = pageSections.filter(':odd');

	if (body.hasClass('page') && pageSections.length > 1) {
		oddSections.addClass('greyish');
	}

	/* Add some "last" classes */
	headerNav.find('.menu-item').last('li').addClass('last');
	$('#top-footer').find('.column').last('.column').addClass('last');
	$('.blog.list-style').find('article').last('article').addClass('last');
	$('.search.list-style').find('article').last('article').addClass('last');

	/* Clear columns */
	var lastColumn = $('.column.last');
	if (lastColumn.length) {
		lastColumn.after('<div class="clear"></div>');
	}

	/* Initialize FluidVids.js */
	Fluidvids.init({
		selector: 'iframe',
		players: ['www.youtube.com', 'player.vimeo.com']
	});

	if ((!body.hasClass('mobile')) && ($('#intro-wrap').length === 0)) {
		var headerHeight = $('header').outerHeight(true);
		$('main').css({
			marginTop: headerHeight + 'px'
		});
	}


	function createfloatMenu() {
		var flMenu = $("#fl_menu");
		if(flMenu.length === 0){
			return;
		}
		
		var floatSpeed = 1500; //milliseconds
		var floatEasing = "easeOut";
		var menuFadeSpeed = 500; //milliseconds
		var closedMenuOpacity = 0.75;

		
		var flMenuMenu = $("#fl_menu .menu");
		var flMenuLabel = $("#fl_menu .label");

		var menuPosition = flMenu.position().top;


		function floatMenu() {
			var scrollAmount = $(document).scrollTop();
			var newPosition = menuPosition + scrollAmount;
			if ($(window).height() < flMenu.height() + flMenuMenu.height()) {
				flMenu.css("top", menuPosition);
			} else {
				flMenu.stop().animate({
					top: newPosition
				}, floatSpeed);
			}
		}


		//floatMenu();
		flMenu.hover(
			function () { //mouse over
				flMenuLabel.fadeTo(menuFadeSpeed, 1);
				flMenuMenu.fadeIn(menuFadeSpeed);
			},
			function () { //mouse out
				flMenuLabel.fadeTo(menuFadeSpeed, closedMenuOpacity);
				flMenuMenu.fadeOut(menuFadeSpeed);
			}
		);

		$(window).scroll(function () {
			//floatMenu();
		});

	}

	createfloatMenu();




});