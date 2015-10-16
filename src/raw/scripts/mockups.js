/*global $*/
$(function () {
	"use strict";

	var body = $('body');

	/* Overlay content absolute centering */
	function centerOverlay() {

		var PortfolioOverlay = $('.overlay-content'),
			BlogOverlay = $('.blog-overlay');
		if (PortfolioOverlay.length) {
			PortfolioOverlay.each(function () {
				var $this = $(this);
				var itemPortfolioHeight = $this.closest('.item').height();
				var PortfolioOverlayHeight = $this.height();
				var PortfolioIcon = $this.children('.post-type');
				var PortfolioIconHeight = PortfolioIcon.children('i').height();

				if ((PortfolioOverlayHeight + 30) > itemPortfolioHeight) {
					$this.children('p').css({
						'visibility': 'hidden'
					});
					$this.children('h2').css({
						'visibility': 'hidden'
					});
					$this.css({
						marginTop: (itemPortfolioHeight - PortfolioIconHeight) / 2
					});
				} else {

					$this.children('p').css({
						'visibility': 'visible'
					});
					$this.children('h2').css({
						'visibility': 'visible'
					});
					$this.css({
						marginTop: (itemPortfolioHeight - PortfolioOverlayHeight) / 2
					});
				}
			});
		}

		if (BlogOverlay.length) {
			BlogOverlay.each(function () {
				var $this = $(this),
					itemBlogHeight = $this.prev('img').height(),
					BlogOverlayIcon = $this.children('i'),
					BlogOverlayIconHeight = BlogOverlayIcon.height();

				BlogOverlayIcon.css({
					top: (itemBlogHeight - BlogOverlayIconHeight) / 2
				});
			});
		}
	}

	centerOverlay();
	$(window).on('load', centerOverlay);
	$(window).on('resize', centerOverlay);

	/* fix Blog Excerpt Heights */
	var blogExcerpt = $('.item.column.three .blog-excerpt');

	function fixBlogH() {

		var gridW = parseInt($('.grid-items').width(), 10);
		var sizerBigW = (gridW / 100) * 48;
		var sizerBigH = sizerBigW * 0.75;
		var sizerSmallW = (gridW / 100) * 22.05;
		var sizerSmallH = sizerSmallW * 0.75;
		var difference = sizerBigH - sizerSmallH + 0.5;

		// console.log(difference);

		if (!body.hasClass('mobile')) {
			blogExcerpt.css({
				'height': difference
			});

		} else {
			blogExcerpt.css({
				'height': 'auto'
			});
		}
	}

	if (blogExcerpt.length) {
		fixBlogH();
		$(window).on('resize', fixBlogH);
	}

	/* Masonry */
	var grid = $('.grid-items');
	var loader = '<div class="landing landing-els"><div class="spinner"><div class="bounce1"></div><div class="bounce2"></div><div class="bounce3"></div></div></div>';

	function masonry() {
		grid.each(function () {
			var $this = $(this),
				filterOptions = $this.prev('.filter-options'),
				sizer = $this.find('.shuffle-sizer');

			$this.append(loader);
			$this.waitForImages({

				finished: function () {
					$this.children('.landing-els').remove();
					$this.shuffle({
						itemSelector: '.item',
						sizer: sizer,
						speed: 500,
						easing: 'ease-out'
					});

					if (filterOptions.length) {
						var btns = filterOptions.children();
						btns.on('click', function () {
							var $this = $(this),
								parentGrid = filterOptions.next(grid),
								isActive = $this.hasClass('active'),
								group = isActive ? 'all' : $this.data('group');
							// Hide current label, show current label in title
							if (!isActive) {
								$('.filter-options .active').removeClass('active');
							}
							$this.toggleClass('active');
							// Filter elements
							parentGrid.shuffle('shuffle', group);
						});

						btns = null;
					}
					$this.removeClass('preload');
					centerOverlay();
				},
				waitForAll: true
			});
		});
	}

	if (grid.length) {
		masonry();
	}

	/* Return the right mockup according to the class & initialize sliders */
	var findDevice = $('.slider');
	function useMockup() {

		findDevice.each(function () {
			var $this = $(this);
			//var slideHeight = $this.find('.owl-item').outerHeight(true);
			var iphoneBlack = '<div class="mockup iphone-mockup black"></div>';
			var iphoneWhite = '<div class="mockup iphone-mockup white"></div>';
			var iphoneGrey = '<div class="mockup iphone-mockup grey"></div>';
			var ipadBlack = '<div class="mockup ipad-mockup black"></div>';
			var ipadWhite = '<div class="mockup ipad-mockup white"></div>';
			var ipadGrey = '<div class="mockup ipad-mockup grey"></div>';
			var desktop = '<div class="mockup desktop-mockup"></div>';
			var deviceWrapper = $this.parent('.row-content');
			var mockupslider = $this.children('figure');
			var autoplay = $this.data('autoplay');

			if (!$this.parent('div').hasClass('side-mockup')) {
				mockupslider.owlCarousel({
					singleItem: true,
					autoPlay: autoplay || false,
					stopOnHover: true,
					responsiveBaseWidth: ".slider",
					responsiveRefreshRate: 0,
					addClassActive: true,
					navigation: true,
					navigationText: [
                        "<i class='fa fa-chevron-left'></i>",
                        "<i class='fa fa-chevron-right'></i>"
                    ],
					pagination: false,
					rewindSpeed: 2000
				});
			} else {
				mockupslider.owlCarousel({
					singleItem: true,
					autoPlay: autoplay || false,
					stopOnHover: true,
					transitionStyle: "fade",
					responsiveBaseWidth: ".slider",
					responsiveRefreshRate: 0,
					addClassActive: true,
					navigation: false,
					pagination: true,
					rewindSpeed: 2000,
					mouseDrag: false,
					touchDrag: false
				});
			}

			if ($this.hasClass('iphone-slider black')) {
				$this.find('.owl-wrapper-outer').after(iphoneBlack);
			} else if ($this.hasClass('iphone-slider white')) {
				$this.find('.owl-wrapper-outer').after(iphoneWhite);
			} else if ($this.hasClass('iphone-slider grey')) {
				$this.find('.owl-wrapper-outer').after(iphoneGrey);
			} else if ($this.hasClass('ipad-slider black')) {
				$this.find('.owl-wrapper-outer').after(ipadBlack);
			} else if ($this.hasClass('ipad-slider white')) {
				$this.find('.owl-wrapper-outer').after(ipadWhite);
			} else if ($this.hasClass('ipad-slider grey')) {
				$this.find('.owl-wrapper-outer').after(ipadGrey);
			} else if ($this.hasClass('desktop-slider')) {
				$this.find('.owl-wrapper-outer').after(desktop);
			}
			$this.waitForImages({
				finished: function () {
					$this.fadeIn('slow');
				},
				waitForAll: true
			});
			deviceWrapper.css({
				'padding-left': '0',
				'padding-right': '0'
			})
		});
	}


	function fixArrowPos() {
		findDevice.each(function () {
			var slideHeight = $(this).find('.owl-item').outerHeight(true);
			$(this).find('.owl-prev, .owl-next').css('top', slideHeight / 2);
		});
	}

	if ((findDevice.length) && (!findDevice.hasClass('gallery'))) {
		useMockup();

		fixArrowPos();
		$(window).resize(fixArrowPos);
	}

	/* Side mockups fixes */
	var sideMockup = $('.side-mockup');

	function sideMockups() {
		sideMockup.each(function () {

			var $this = $(this);
			var sideMockupHeight = parseInt($this.find('.slider').height(),10);
			var sideMockupParent = $this.parent('.row-content');
			var sideMockupParentPad = parseInt(sideMockupParent.css('padding-top'),10);
			var sideMockupFix = sideMockupHeight + (sideMockupParentPad * 2) + 'px';

			if (!body.hasClass('mobile')) {
				if ($this.hasClass('right-mockup')) {
					$this.css({
						'position': 'absolute',
						'left': '52%'
					});
				} else if ($this.hasClass('left-mockup')) {
					$this.css({
						'position': 'absolute',
						'right': '52%'
					});
				}
				sideMockupParent.css({
					'position': 'relative',
					'min-height': sideMockupFix
				});
			} else {
				$this.css({
					'position': 'relative',
					'left': 'auto',
					'right': 'auto'
				});
				sideMockupParent.css({
					'position': 'relative',
					'min-height': '0'
				});
			}
		});
	}


	if (sideMockup.length) {
		sideMockups();
		$(window).resize(sideMockups);
	}

});