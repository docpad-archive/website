/*global $*/
$(function () {
	"use strict";

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
/*					$this.css({
						marginTop: (itemPortfolioHeight - PortfolioIconHeight) / 2
					});*/
				} else {

					$this.children('p').css({
						'visibility': 'visible'
					});
					$this.children('h2').css({
						'visibility': 'visible'
					});
/*					$this.css({
						marginTop: (itemPortfolioHeight - PortfolioOverlayHeight) / 2
					});*/
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
});