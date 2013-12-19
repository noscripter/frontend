/**
 * DisableOnSubmit
   * A plugin to disable forms on submit to
   * try and prevent erroneous/malicious
   * resubmitting and duplication
 *

 * Example usage:
 $('.myForm').disableOnSubmit({
    submitButton: $('.mybutton'); // override default selector
 });
**/

;(function ( $, window, document, undefined ) {

    // Defaults
    var disableOnSubmit = "disableOnSubmit",
        defaults = {
            submitButton : $('button[type="submit"], input[type="submit"]')
        };

    // The actual plugin constructor
    function DisableOnSubmit( form, options ) {
        this.form = form;

        // Merge options
        this.options = $.extend( {}, defaults, options) ;

        this._defaults = defaults;
        this._name = disableOnSubmit;

        this.setup();
    }

    DisableOnSubmit.prototype = {

        setup: function() {
            var _self = this;
            // Add event listener to the form
            $(this.form).on('submit', function(){
                _self.checkDisabled();
            });
            // Add event listener to the element tasked with submitting the form
            this.options.submitButton.on('submit click', function(){
                _self.checkDisabled();
            });
        },

        checkDisabled: function(el, options) {
            var $el = $(this.form),
                $button = this.options.submitButton;

            if( $el.is(':disabled')      || $button.is(':disabled') ||
                $el.hasClass('disabled') || $button.hasClass('disabled'))
                return false;

            // Disable them before submitting happens
            this.disable([$el,$button],true);
        },

        disable: function(elements,submit){
            var _self = this;

            $(elements).each(function(){
                $(this).addClass("disabled").attr("disabled",true);
            });

            console.log(elements,submit);

            // When everything has finished disabling, submit the form
            if(typeof submit !== "undefined" && submit){
                return _self.submit();
            }
        },

        enable: function($elements){
            $(elements).each(function(){
                $(this).removeClass("disabled").attr("disabled",false);
            });
        },

        submit: function(){
            $(this.form).submit();
        }

    };

    // Wrapper to prevent multiple instantiations
    $.fn[disableOnSubmit] = function ( options ) {
        return this.each(function () {
            if (!$.data(this, "plugin_" + disableOnSubmit)) {
                $.data(this, "plugin_" + disableOnSubmit,
                new DisableOnSubmit( this, options ));
            }
        });
    };

})( jQuery, window, document );
