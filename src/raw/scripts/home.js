/*global $, skrollr*/
$(function () {
	"use strict";

	var win = $(window);
	var body = $('body');
	var pxWrapper = $('#intro-wrap');
	var header = $('header');


	/* Intro Height */
	function introHeight() {

		var $this = pxWrapper;
		var dataHeight = $this.data('height');
		if ($this.hasClass('full-height')) {
			var recalcHeaderH = header.outerHeight(true);
			if (!body.hasClass('mobile')) {
				$this.css({
					'height': (win.height())
				});
			} else {
				$this.css({
					'height': (win.height() - recalcHeaderH)
				});
			}
		} else {
			$this.css({
				'height': dataHeight + 'em'
			});
		}
	}

	var pxContainer = $('#intro');
	var loaderIntro = '<div class="landing landing-slider"><div class="spinner"><div class="bounce1"></div><div class="bounce2"></div><div class="bounce3"></div></div></div>';
	var pxImg = $('.intro-item');
	var darkover = '<div class="darkover"></div>';
	var moreBtnIcon = '<div class="more"><a href="#main"><i class="icon icon-arrow-down"></i></a></div>';
	var smoothScroll = smoothScroll || $.noop;

	/* Initialize Intro */
	function initIntro() {
		var $this = pxContainer;
		$this.append(loaderIntro);
		$this.addClass(function () {
			return $this.find('.intro-item').length > 1 ? "big-slider" : "";
		});

		$this.waitForImages({

			finished: function () {

				// console.log('All images have loaded.');
				$('.landing-slider').remove();

				if ($this.hasClass('big-slider')) {

					var autoplay = $this.data('autoplay');
					var navigation = $this.data('navigation');
					var pagination = $this.data('pagination');
					var transition = $this.data('transition');

					$this.owlCarousel({
						singleItem: true,
						autoPlay: autoplay || false, // || = if data- is empty or if it does not exists
						transitionStyle: transition || false,
						stopOnHover: true,
						responsiveBaseWidth: ".slider",
						responsiveRefreshRate: 0,
						addClassActive: true,
						navigation: navigation || false,
						navigationText: [
                            "<i class='icon icon-arrow-left-simple'></i>",
                            "<i class='icon icon-arrow-right-simple'></i>"
                        ],
						pagination: pagination || false,
						rewindSpeed: 2000
					});
				}
				$this.removeClass('preload');
				if ($this.hasClass('darken')) {
					pxImg.append(darkover);
				}
				if (pxWrapper.length && $this.hasClass('more-button') && $this.attr('data-pagination') !== 'true') {
					$this.append(moreBtnIcon);
					smoothScroll();
				}
			},
			waitForAll: true
		});
	}
	if (pxContainer.length) {
		initIntro();
		introHeight();
		$(window).resize(introHeight);
	}

	/* Parallax data attributes according to #intro's height */
	var content = $('main');
	var pxImgCaption = pxContainer.find('.caption');
	var headerHeight = header.outerHeight(true);

	function parallax() {

		if (pxWrapper.length) {
			var touchDevice = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
			if (touchDevice) {
				body.addClass('no-parallax');
			} else if (!body.hasClass('mobile') && !body.hasClass('no-parallax')) {
				pxContainer.attr('data-anchor-target', '#intro-wrap');
				pxContainer.attr('data-top', 'transform:translateY(0px);');
				header.attr('data-anchor-target', '#intro-wrap');
				header.attr('data-top', 'transform:translateY(0px);');
				if (touchDevice) {
					pxContainer.attr('data-top-bottom', 'transform:translateY(0px);');
					header.attr('data-top-bottom', 'transform:translateY(0px);');
					header.addClass('transition');
					// console.log('Disable Parallax');
				} else {
					pxContainer.attr('data-top-bottom', 'transform:translateY(' + '-' + pxWrapper.height() / 4 + 'px);');
					header.attr('data-top-bottom', 'transform:translateY(' + '-' + pxWrapper.height() / 4 + 'px);');
				}
				var animDone = false;

				skrollr.init({
					forceHeight: false,
					smoothScrolling: false,
					mobileCheck: function () {
						//hack - forces mobile version to be off
						return false;
					},
					/* easing: 'swing', */
					render: function () {

							if (header.hasClass('skrollable-after')) {
								if (!animDone) {
									animDone = true;
									header.addClass('fixed-header').css({
										'display': 'none'
									}).fadeIn(300);
								}
							} else {
								animDone = false;
								header.removeClass('fixed-header');
							}
						}
						/*
						render: function(data) {
						    //Log the current scroll position.
						    console.log(data.curTop);
						}
						*/
				}).refresh();

				pxImgCaption.each(function () {
					var $this = $(this);
					$this.css({
						top: ((pxWrapper.height() + headerHeight / 2) - $this.outerHeight()) / 2
					});
				});
			} else {
				skrollr.init().destroy();
				content.css({
					marginTop: 0 + 'px'
				});

				var parallaxEls = $('header, #intro'),
					attrs = parallaxEls[0].attributes,
					name,
					index;

				for (index = attrs.length - 1; index >= 0; --index) {
					name = attrs[index].nodeName;
					if (name.substring(0, 5) === "data-") {
						parallaxEls.removeAttr(name);
					}
				}

				parallaxEls.css({
					'-webkit-transform': '',
					'-moz-transform': '',
					'transform': '',
					'backgroundPosition': ''
				}).removeClass('skrollable-after');

				pxImgCaption.each(function () {
					var $this = $(this);
					if (!body.hasClass('mobile') && body.hasClass('no-parallax')) {
						$this.css({
							top: ((pxWrapper.height() + headerHeight) - $this.outerHeight()) / 2
						});
					} else {
						$this.css({
							top: (pxWrapper.height() - $this.outerHeight()) / 2
						});
					}
				});
			}
		} else {
			if (!body.hasClass('mobile')) {
				content.css({
					marginTop: headerHeight + 'px'
				});
			} else {
				content.css({
					marginTop: 0
				});
			}
		}
	}
	parallax();
	$(window).resize(parallax);

	/* onScreen Animations */
	var onScreenAnims = $('.animation');
	if (onScreenAnims.length) {
		onScreenAnims.onScreen({
			toggleClass: false,
			doIn: function () {
				$(this).addClass('onscreen')
			}
		});
	}

	
	/* Counters */
    var countItem = $('.count-item');
    function milestone() {

        countItem.each(function () {
            var $this = $(this);
            $this.onScreen({
                doIn: function () {
                    var countNumber = $this.find('.count-number');
                    var countTitle = $this.find('.count-subject');
                    countNumber.countTo({
                        onComplete: function () {
                            countTitle.delay(100).addClass('subject-on');
                            countNumber.removeClass('count-number').addClass('count-number-done');
                        }
                    });
                }
            });
        });
    }

    if (countItem.length) {
        milestone();
    }

});