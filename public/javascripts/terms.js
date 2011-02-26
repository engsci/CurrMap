// Make tree editing forms toggleable
$(document).ready(
  function() {
    $('.add-tok-node').replaceWith(function() {
      var node = this;
      if (!node.parentElement || !node.parentElement) {
        return;
      }

      var formContainer = $('.add-tok-form', node.parentElement.parentElement);
      var anchor = document.createElement('a');
      $(anchor).attr({href: '#'});
      $(anchor).click(function(evt) {
        evt.preventDefault();
        formContainer.toggleClass('hidden');
        if (anchor.innerHTML === '+') {
          anchor.innerHTML = '-';
        } else {
          anchor.innerHTML = '+';
        }
      });
      anchor.innerHTML = '+';
      return anchor;
    });
});
// Autocomplete for term names
$(document).ready(
  function() {
    $('.termComplete').autocomplete({
      source: '/terms/search.json'
    });
});
