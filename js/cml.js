/*!
 * Start Bootstrap - Agnecy Bootstrap Theme (http://startbootstrap.com)
 * Code licensed under the Apache License v2.0.
 * For details, see http://www.apache.org/licenses/LICENSE-2.0.
 */

// jQuery for page scrolling feature - requires jQuery Easing plugin
$(function() {
    $('a.page-scroll').bind('click', function(event) {
        var $anchor = $(this);
        $('html, body').stop().animate({
            scrollTop: $($anchor.attr('href')).offset().top
        }, 1500, 'easeInOutExpo');
        event.preventDefault();

        // GA track clicks
        console.info('send', 'event', 'Link', 'click', $anchor.text());
        ga('send', 'event', 'Link', 'click', $anchor.text())
    });

    var introText = $('.intro-text');
    var padding = $(window).height() - introText.height();
    if (padding < 160)
        padding = 160;
    introText.css('padding-top', padding / 2 + 'px');
    introText.css('padding-bottom', padding / 2 + 'px');
});

// Highlight the top nav as scrolling occurs
$('body').scrollspy({
    target: '.navbar-fixed-top'
});

// Closes the Responsive Menu on Menu Item Click
$('.navbar-collapse ul li a').click(function() {
    $('.navbar-toggle:visible').click();
});

$('div.modal').on('show.bs.modal', function() {
	var modal = this;
	var hash = modal.id;
	window.location.hash = hash;
	window.onhashchange = function() {
		if (!location.hash){
			$(modal).modal('hide');
		}
	}
});

Typed.new("#typed-animation", {
    strings: ["Chatbots^1500", "Data Science^1500", "Blockchain^1500", "IT Consulting^1500"]
    , typeSpeed: 100
    , startDelay: 100
    , loop: true
});
