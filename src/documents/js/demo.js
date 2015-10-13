/*global document, $*/
$(document).ready(function () {
    var colCss = $('#colcss');
    var cssFiles = {
        Mauve: '/css/color-mauve.css',
        Blue: '/css/color-blue.css',
        Red: '/css/color-red.css',
        Orange: '/css/color-orange.css',
        Green: '/css/color-green.css'
    };
    
    //preload css
    for(var item in cssFiles){
        $.get(cssFiles[item],function(){
            console.log("Got: "+item);
        });
    }
    
    
    $('.colours li').click(function () {
        var val = $(this).text();
        var file = cssFiles[val];
        if (file) {
            colCss.attr('href', file);
        }

    });
});