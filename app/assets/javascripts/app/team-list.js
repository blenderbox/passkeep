/* 
Call the teamList with $('jquery-selector').teamList({ url:'the-search-url' });
*/

(function($) {
    var TeamList = function(el, opts) {
        //Defaults are below
        var settings = $.extend({}, $.fn.teamList.defaults, opts);
        var $el, $search, $list, $tokens;
        // private methods
        function init() {
            $el = $(el);
            $list = $el.find('ul');
            $tokens = $el.find('input:hidden');
            $search = $el.find('input[type=search]');
            $search.autocomplete({ select:onSelect, source:settings.url });
            $el.find('.close').live('click', onRemove);
        }
        function serialize() {
            ids = [];
            $list.find('li').each(function(idx, el){
                ids[ids.length] = $(el).data('id');
            });
            $tokens.val(ids.join(','));
        }
        function onRemove(e) {
            $(e.currentTarget).parent().remove();
            serialize();
        }
        function onSelect(e, ui) {
            $list.append('<li data-id="' + ui.item.id + '"><a class="close" title="remove">&times;</a> ' + ui.item.name + '</li>');
            serialize();
        }
        init();
    };
    $.fn.teamList = function(options) {
        return this.each(function(idx, el) {
            var $el = $(this), key = 'teamList';
            // Return early if this element already has a plugin instance
            if ($el.data(key)) { return; }
            // Pass options to plugin constructor
            var teamList = new TeamList(this, options);
            // Store plugin object in this element's data
            $el.data(key, teamList);
        });
    };
    // default settings
    $.fn.teamList.defaults = { url:'' };
})(jQuery);