"use strict";
function setVideoHeights() {

    // youtube
    jQuery(document).find('iframe[src*="youtube.com"]').each(function() {
        jQuery(this).css('height', jQuery(this).attr('width', '100%').width() * 0.56, 'important');
    })

    // vimeo
    jQuery(document).find('iframe[src*="vimeo.com"]').each(function() {
        jQuery(this).css('height', jQuery(this).attr('width', '100%').width() * 0.56, 'important');
    })

    // youtube
    jQuery(document).find('iframe[src*="dailymotion.com"]').each(function() {
        jQuery(this).css('height', jQuery(this).attr('width', '100%').width() * 0.56, 'important');
    })

}

"use strict";
// Ajax Post Views Counter
var miptheme_ajax_post_views = {

    get_post_views : function get_post_views (post_array_ids) {
        jQuery.ajax({
            type: 'POST',
            url: miptheme_ajax_url.ajaxurl,
            cache: true,
            data: {
                action: "miptheme_ajax_update_views",
                post_ids: post_array_ids
            },
            success: function(data, textStatus, XMLHttpRequest){
                var ajax_post_counts = jQuery.parseJSON(data);//get the return dara

                if (ajax_post_counts instanceof Object) {
                    jQuery.each(ajax_post_counts, function(id_post, value) {
                        var current_post_count = ".post-view-counter-" + id_post;
                        jQuery(current_post_count).html(value);
                    });
                }
            },
            error: function(MLHttpRequest, textStatus, errorThrown){
            }
        });
    }

};

"use strict";
(function($) {

    $(window).load(function() {
        $('[data-retina]').each(function() {

            var img = new Image();
            img.src = $(this).attr('data-retina');

            if(window.devicePixelRatio >= 2) {
                $(this).attr('src', img.src);
            }

        });
    });


    // Navigation Menu Expander
    $(function() {
        $('nav#mobile-menu').mmenu({
            offCanvas: {
                position: "left",
                zposition : "front"
            },
            searchfield: false
        });
    });


    // Navigation slide down
    $("#menu .nav li").hover(function(){
        $(this).stop(true, true).find('.dropnav-container, .subnav-container').slideDown(100);
    },function(){
        $(this).stop(true, true).find('.dropnav-container, .subnav-container').hide();
    });

    // Subnav article loader
    $('#menu .subnav-menu li:first-child').addClass('current');

    $('#menu .subnav-menu li').hover(function() {
        $(this).parent().find('li').removeClass('current');
        $(this).addClass('current');
    });


    $('#search-nav-button').click(function(){
        $(this).delay(200).queue(function(){
            document.getElementById("nav-search").focus();
            $(this).dequeue();
        });
    });

    $('.dropdown-menu').find('form').click(function (e) {
        e.stopPropagation();
    });


    // Weather Data
    if ( !(typeof(weather_widget) === 'undefined') && weather_widget) {
        if (weather_location == '') {
            if (getCookie('weeklynews_weather') === null) {
                $.getJSON('https://freegeoip.net/json/')
                 .done (function(location)
                 {
                     weather_location = location.city +', '+ location.country_name;
                     setCookie('weeklynews_weather', weather_location);
                     GetWeatherData(weather_lang, weather_location, weather_unit)
                 });
            } else {
                GetWeatherData(weather_lang, getCookie('weeklynews_weather'), weather_unit)
            }
        } else {
            GetWeatherData(weather_lang, weather_location, weather_unit)
        }
    }


    function GetWeatherData(sLang, sLocation, sUnit) {
        $('#weather .temp').customOpenWeather({
            lang: ''+ sLang +'',
            city: ''+ sLocation +'',
            placeTarget: '#weather .location',
            units: ''+ sUnit +'',
            descriptionTarget: '#weather .desc',
            iconTarget: '#weather i.icon',
            success: function() {
                $('#weather').show();
            },
            error: function(message) {
                console.log(message);
            }
        });
    }


    if ( !(typeof(initCarouFredSel) === 'undefined') && initCarouFredSel) {
        $('#slider-carousel').carouFredSel({
            width: '100%',
            height: 'variable',
            prev: '#slider-prev',
            next: '#slider-next',
            responsive: true,
            transition: true,
            items: {
                height: 'variable',
            },
            swipe: {
                onMouse: true,
                onTouch: true
            },
            scroll : {
                items           : 1,
                easing          : "quadratic",
                duration        : 1000,
                pauseOnHover    : true
            },
            auto : {
                play            : carouselStart,
                delay           : carouselDelay,
            },
            onCreate: function () {
                setTimeout(function() {
                    $('#page-slider .bttrlazyloading').trigger('bttrlazyloading.load');
                }, 1000);
                $(window).on('resize', function () {
                    var carousel = $('#slider-carousel');
                    carousel.parent().add(carousel).height(carousel.children().first().height()+'px');
                }).trigger('resize');
            }
        }).trigger('resize');

        $('#slider-carousel').swipe({
            tap:function (event, target) {
                $(target).click();
            },
            swipe:function(event, direction, distance, duration, fingerCount) {
            },
            threshold:50
        });
    }


    if ( !(typeof(initModuleCarousel) === 'undefined') && initModuleCarousel) {
        $('.module-carousel .wrapper').carouFredSel({
            width: '100%',
            height: ''+ modCarHeight +'px',
            prev    : {
                button  : function(){
                    return $(this).parents('.module-carousel').find('.prev');
                }
            },
            next    : {
                button  : function(){
                    return $(this).parents('.module-carousel').find('.next');
                }
            },
            responsive: true,
            transition: true,
            swipe: {
                onMouse: true,
                onTouch: true
            },
            auto : {
                play            : modCarAutoStart
            },
            scroll : {
                items           : 1,
                easing          : "quadratic",
                duration        : 600,
                pauseOnHover    : true,
                onAfter: function( data ) {
                    var pos = $(".module-carousel .wrapper").triggerHandler("currentPosition") + 1;
                    $(".module-carousel figure .index").text( pos );
                }
            }
        });

        $('.module-carousel .wrapper').swipe({
            tap:function (event, target) {
                $(target).click();
            },
            swipe:function(event, direction, distance, duration, fingerCount) {
            },
            threshold:50
        });

        $('.module-carousel figcaption a.pix').click(function(e){
            e.preventDefault();
            $(this).closest("figure").children('a.pix').click();
        });
    }


    if ( !(typeof(initBreakingNews) === 'undefined') && initBreakingNews) {
        $('#breaking-news-carousel').carouFredSel({
            width: '100%',
            height: 'auto',
            direction: 'up',
            items: 1,
            scroll: {
                duration: 1000,
                onBefore: function( data ) {
                    data.items.visible.children().css( 'opacity', 0 ).delay( 200 ).fadeTo( 400, 1 );
                    data.items.old.children().fadeTo( 400, 0 );
                }
            }
        });
    }

    // Init photobox
    $('.weekly-gallery').photobox('a',{ time:0 });
    $('.module-carousel').photobox('figure > a.pix',{ time:0 });
    $('#article-gallery').photobox('a',{ time:0 });
    $('.zoom-photo').photobox('a',{ time:0 });
    $('#main').photobox('a.photobox',{ time:0 });

    // Init datepicker for archive page
    $('#archive-date-picker').datepicker({
        format: 'mm/yyyy',
        viewMode: 'months',
        minViewMode: 'months'
    }).on('changeDate', function(ev){
        var nYear = ev.date.getFullYear();
        var nMonth = ( ev.date.getMonth() < 8 ) ? '0' + (ev.date.getMonth()+1) : (ev.date.getMonth()+1);
        window.location.href = '/?m='+ nYear +''+ nMonth;
    });

    //Click event to scroll to top
    $('.scrollToTop').click(function(){
        $('html, body').animate({scrollTop : 0},800);
        return false;
    });

    // Set page header height
    if ($('#page-header').height() > 0) $('#page-header').height($("#page-header").height());

    // Set Parallax header
    var top_header = $('.head-image-parallax');
    $(window).scroll(function () {
      var st = $(window).scrollTop();
      top_header.css({'background-position':"center -"+(st*.3)+"px"});
    });

    // Resize video iframes
    setVideoHeights();


    // Placeholder for non supportive
    $('input, textarea').placeholder();

    // Get social shares
    if ( !(typeof(smStats) === 'undefined') && smStats) {
        smStats = new SocialMediaStats( smStats );
        if (smStatsFacebook) smStats.facebookCount('smFacebook');
        if (smStatsTwitter) smStats.twitterCount('smTwitter');
        //if (smStatsGoogle) smStats.facebookCount('smGoogle
        if (smStatsLinkedIn) smStats.linkedinCount('smLinkedin');
    }


    // Lazy Loading
    $('.bttrlazyloading').bttrlazyloading({
        backgroundcolor: '#fff',
        animation: 'fadeIn'
    });


    // Smooth Scrolling
    if ( !(typeof(miptheme_smooth_scrolling) === 'undefined') && miptheme_smooth_scrolling) {
        smooth_scroll();
    }


    // Ajax paging
    $('.mip-ajax-nav a').click(function(e){
        e.preventDefault();
        var element             = this;
        var nIndex              = parseInt( $(this).attr('data-index') );
        var sContainer          = '#'+ $(this).attr('data-container');
        var nMaxPages           = parseInt( $(sContainer).attr('data-max-pages') );

        if ( (nIndex == 0) || (nIndex == nMaxPages )) { return; }

        //search the cache
        var currentContainerObj = JSON.stringify(sContainer +'-'+ $(this).attr('data-index'));
        if ( mipthemeLocalCache.exist(currentContainerObj) ) {
            processResponse( mipthemeLocalCache.get(currentContainerObj), element, sContainer );
            return;
        }

        var sContainerArticles  = sContainer + ' .articles';
        var sArticles           = sContainerArticles + ' article';
        $.ajax({
            url: miptheme_ajax_url.ajaxurl,
            type: 'post',
            data: {
                action: 'miptheme_ajax_blocks',
                data_block: $(sContainer).attr('data-block'),
                data_index: $(this).attr('data-index'),
                data_cat: $(sContainer).attr('data-cat'),
                data_count: $(sContainer).attr('data-count'),
                data_offset: $(sContainer).attr('data-offset'),
                data_tag: $(sContainer).attr('data-tag'),
                data_sort: $(sContainer).attr('data-sort'),
                data_display: $(sContainer).attr('data-display'),
                data_img_format_1: $(sContainer).attr('data-img-format-1'),
                data_img_format_2: $(sContainer).attr('data-img-format-2'),
                data_img_width_1: $(sContainer).attr('data-img-width-1'),
                data_img_width_2: $(sContainer).attr('data-img-width-2'),
                data_img_height_1: $(sContainer).attr('data-img-height-1'),
                data_img_height_2: $(sContainer).attr('data-img-height-2'),
                data_text: $(sContainer).attr('data-text'),
                data_columns: $(this).attr('data-columns'),
                data_layout: $(this).attr('data-layout')
            },
            beforeSend: function() {
                $(sArticles).addClass('ajax-opacity');
                $(sContainerArticles).append('<span class="ajax-loading"><div class="loader">Loading...</div></span>');
                $(sContainerArticles).wrapInner( $( '<aside class="clearfix"></aside>' ) );
                $(sContainerArticles).css( 'height', ''+ $('aside:first',sContainerArticles).height() +'px' );
            },
            complete: function( xhr, status ) {
                $(sContainerArticles + ' .ajax-loading').remove();
            },
            success: function( data ) {
                mipthemeLocalCache.set(currentContainerObj, data);
                processResponse( data, element, sContainer );
            }
        })
    });


    function processResponse( data, element, sContainer ) {
        var sContainerArticles  = sContainer + ' .articles';
        var sArticles           = sContainerArticles + ' article';

        $(sContainerArticles).removeClass('animated fadeIn');
        $(sArticles).fadeOut(700, function() {
            $(sArticles).remove();
            $(sContainerArticles).html( data ).addClass('animated fadeIn');
            $(sContainerArticles).wrapInner( $( '<aside class="clearfix"></aside>' ) );

        });

        if ( $(element).hasClass('prev') ) {
            setPrevIndex( sContainer );
        } else {
            setNextIndex( sContainer );
        }

        setTimeout(function() {
            var newheight = $('aside:first',$(sContainerArticles)).height();
            $(sContainerArticles).animate( {height: newheight} );
            if (newheight > $(window).height()) {
                $("html, body").stop().animate({ scrollTop: $( sContainer ).offset().top - 30 }, 1000);
            }
        }, miptheme_ajaxpagination_timer);
    }


    function setNextIndex( sContainer ) {
        $(sContainer + ' .mip-ajax-nav a').removeClass('disabled');
        var sPrev   = sContainer + ' .mip-ajax-nav a.prev';
        var sNext   = sContainer + ' .mip-ajax-nav a.next';
        $(sPrev).attr('data-index', parseInt($(sPrev).attr('data-index'))+1);
        $(sNext).attr('data-index', parseInt($(sNext).attr('data-index'))+1);
        if ( $(sNext).attr('data-index') == $(sContainer).attr('data-max-pages') ) {
            $(sNext).addClass('disabled');
        }
    }

    function setPrevIndex( sContainer ) {
        $(sContainer + ' .mip-ajax-nav a').removeClass('disabled');
        var sPrev   = sContainer + ' .mip-ajax-nav a.prev';
        var sNext   = sContainer + ' .mip-ajax-nav a.next';
        $(sPrev).attr('data-index', parseInt($(sPrev).attr('data-index'))-1);
        $(sNext).attr('data-index', parseInt($(sNext).attr('data-index'))-1);
        if ( $(sPrev).attr('data-index') == 0 ) {
            $(sPrev).addClass('disabled');
        }
    }

})(jQuery);
