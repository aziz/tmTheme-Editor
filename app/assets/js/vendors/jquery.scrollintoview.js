/*!
 * jQuery scrollintoview() plugin and :scrollable selector filter
 *
 * Version 1.8 (14 Jul 2011)
 * Requires jQuery 1.4 or newer
 *
 * Copyright (c) 2011 Robert Koritnik
 * Licensed under the terms of the MIT license
 * http://www.opensource.org/licenses/mit-license.php
 */

(function ($) {
	var converter = {
		vertical: { x: false, y: true },
		horizontal: { x: true, y: false },
		both: { x: true, y: true },
		x: { x: true, y: false },
		y: { x: false, y: true }
	};

	var settings = {
		duration: "fast",
		direction: "both",
		viewPadding: 0
	};

	var rootrx = /^(?:html)$/i;

	// gets border dimensions
	var borders = function (domElement, styles) {
		styles = styles || (document.defaultView && document.defaultView.getComputedStyle ? document.defaultView.getComputedStyle(domElement, null) : domElement.currentStyle);
		var px = document.defaultView && document.defaultView.getComputedStyle ? true : false;
		var b = {
			top: (parseFloat(px ? styles.borderTopWidth : $.css(domElement, "borderTopWidth")) || 0),
			left: (parseFloat(px ? styles.borderLeftWidth : $.css(domElement, "borderLeftWidth")) || 0),
			bottom: (parseFloat(px ? styles.borderBottomWidth : $.css(domElement, "borderBottomWidth")) || 0),
			right: (parseFloat(px ? styles.borderRightWidth : $.css(domElement, "borderRightWidth")) || 0)
		};
		return {
			top: b.top,
			left: b.left,
			bottom: b.bottom,
			right: b.right,
			vertical: b.top + b.bottom,
			horizontal: b.left + b.right
		};
	};

	var dimensions = function ($element) {
		var elem = $element[0],
			isRoot = rootrx.test(elem.nodeName),
			$elem = isRoot ? $(window) : $element;
		return {
			border: isRoot ? { top: 0, left: 0, bottom: 0, right: 0} : borders(elem),
			scroll: {
				top: $elem.scrollTop(),
				left: $elem.scrollLeft(),
				maxtop: elem.scrollHeight - elem.clientHeight,
				maxleft: elem.scrollWidth - elem.clientWidth
			},
			scrollbar: isRoot
				? { right: 0, bottom: 0 }
				: {
					right: $elem.innerWidth() - elem.clientWidth,
					bottom: $elem.innerHeight() - elem.clientHeight
				}
			,
			rect: isRoot ? { top: 0, left: 0, bottom: elem.clientHeight, right: elem.clientWidth } : elem.getBoundingClientRect()
		};
	};

	$.fn.extend({
		scrollintoview: function (options) {
			/// <summary>Scrolls the first element in the set into view by scrolling its closest scrollable parent.</summary>
			/// <param name="options" type="Object">Additional options that can configure scrolling:
			///        duration (default: "fast") - jQuery animation speed (can be a duration string or number of milliseconds)
			///        direction (default: "both") - select possible scrollings ("vertical" or "y", "horizontal" or "x", "both")
			///        complete (default: none) - a function to call when scrolling completes (called in context of the DOM element being scrolled)
			/// </param>
			/// <return type="jQuery">Returns the same jQuery set that this function was run on.</return>

			options = $.extend({}, settings, options);
			options.direction = converter[typeof (options.direction) === "string" && options.direction.toLowerCase()] || converter.both;

			if (typeof options.viewPadding == "number") {
				options.viewPadding = { x: options.viewPadding , y: options.viewPadding };
			} else if (typeof options.viewPadding == "object") {
				if (options.viewPadding.x == undefined) {
					options.viewPadding.x = 0;
				}
				if (options.viewPadding.y == undefined) {
					options.viewPadding.y = 0;
				}
			}

			var dirStr = "";
			if (options.direction.x === true) dirStr = "horizontal";
			if (options.direction.y === true) dirStr = dirStr ? "both" : "vertical";

			var el = this.eq(0);
			var scroller = el.parent().closest(":scrollable(" + dirStr + ")");

			// check if there's anything to scroll in the first place
			if (scroller.length > 0)
			{
				scroller = scroller.eq(0);

				var dim = {
					e: dimensions(el),
					s: dimensions(scroller)
				};

				var rel = {
					top: dim.e.rect.top - (dim.s.rect.top + dim.s.border.top),
					bottom: dim.s.rect.bottom - dim.s.border.bottom - dim.s.scrollbar.bottom - dim.e.rect.bottom,
					left: dim.e.rect.left - (dim.s.rect.left + dim.s.border.left),
					right: dim.s.rect.right - dim.s.border.right - dim.s.scrollbar.right - dim.e.rect.right
				};

				var animProperties = {};

				// vertical scroll
				if (options.direction.y === true)
				{
					if (rel.top < 0)
					{
						animProperties.scrollTop = Math.max(0, dim.s.scroll.top + rel.top - options.viewPadding.y);
					}
					else if (rel.top > 0 && rel.bottom < 0)
					{
						animProperties.scrollTop = Math.min(dim.s.scroll.top + Math.min(rel.top, -rel.bottom) + options.viewPadding.y, dim.s.scroll.maxtop);
					}
				}

				// horizontal scroll
				if (options.direction.x === true)
				{
					if (rel.left < 0)
					{
						animProperties.scrollLeft = Math.max(0, dim.s.scroll.left + rel.left - options.viewPadding.x);
					}
					else if (rel.left > 0 && rel.right < 0)
					{
						animProperties.scrollLeft = Math.min(dim.s.scroll.left + Math.min(rel.left, -rel.right) +  options.viewPadding.x, dim.s.scroll.maxleft);
					}
				}

				// scroll if needed
				if (!$.isEmptyObject(animProperties))
				{
					var scrollExpect = {},
						scrollListener = scroller;

					if (rootrx.test(scroller[0].nodeName)) {
						scroller = $("html,body");
						scrollListener = $(window);
					}

					function animateStep(now, tween) {
						scrollExpect[tween.prop] = Math.floor(now);
					};
					function onscroll(event) {
						$.each(scrollExpect, function(key, value) {
							if (scrollListener[key]() != value) {
								options.complete = null;	// don't run complete function if the scrolling was interrupted
								scroller.stop('scrollintoview');
							}
						});
					}
					scrollListener.on('scroll', onscroll);

					scroller
						.stop('scrollintoview')
						.animate(animProperties, { duration: options.duration, step: animateStep, queue: 'scrollintoview' })
						.eq(0) // we want function to be called just once (ref. "html,body")
						.queue('scrollintoview', function (next) {
							scrollListener.off('scroll', onscroll);
							$.isFunction(options.complete) && options.complete.call(scroller[0]);
							next();
						})

					scroller.dequeue('scrollintoview');
				}
				else
				{
					// when there's nothing to scroll, just call the "complete" function
					$.isFunction(options.complete) && options.complete.call(scroller[0]);
				}
			}

			// return set back
			return this;
		}
	});

	var scrollValue = {
		auto: true,
		scroll: true,
		visible: false,
		hidden: false
	};

	$.extend($.expr[":"], {
		scrollable: function (element, index, meta, stack) {
			var direction = converter[typeof (meta[3]) === "string" && meta[3].toLowerCase()] || converter.both;
			var styles = (document.defaultView && document.defaultView.getComputedStyle ? document.defaultView.getComputedStyle(element, null) : element.currentStyle);
			var overflow = {
				x: scrollValue[styles.overflowX.toLowerCase()] || false,
				y: scrollValue[styles.overflowY.toLowerCase()] || false,
				isRoot: rootrx.test(element.nodeName)
			};

			// check if completely unscrollable (exclude HTML element because it's special)
			if (!overflow.x && !overflow.y && !overflow.isRoot)
			{
				return false;
			}

			var size = {
				height: {
					scroll: element.scrollHeight,
					client: element.clientHeight
				},
				width: {
					scroll: element.scrollWidth,
					client: element.clientWidth
				},
				// check overflow.x/y because iPad (and possibly other tablets) don't dislay scrollbars
				scrollableX: function () {
					return (overflow.x || overflow.isRoot) && this.width.scroll > this.width.client;
				},
				scrollableY: function () {
					return (overflow.y || overflow.isRoot) && this.height.scroll > this.height.client;
				}
			};
			return direction.y && size.scrollableY() || direction.x && size.scrollableX();
		}
	});
})(jQuery);
