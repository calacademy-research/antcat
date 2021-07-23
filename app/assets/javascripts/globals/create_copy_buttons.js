// TODO: This is horrible for so many reasons (mutates in place, jQuery-like, etc).
// It will remain horrible for some time since it's used both in Sprockets JS and Vue.
// And it's ES5.

$(function() {
  window.AntCat.CreateCopyButtons(document);
});

window.AntCat.CreateCopyButtons = function(element) {
  if (!element) {
    return;
  }

  element.querySelectorAll('[data-copy-to-clipboard]').forEach(function(item) {
    item.addEventListener('click', function(event) {
      event.preventDefault()
      var stringToCopy = item.getAttribute('data-copy-to-clipboard');
      CopyToClipboard(stringToCopy);

      // TODO: Do not use global function once we ready to drop/migrate the jQuery version.
      AntCat.notifySuccess('Copied "' + stringToCopy + '" to clipboard');
    });
  });
};

var CopyToClipboard = function CopyToClipboard(stringToCopy) {
  var tempEl = document.createElement('textarea');
  tempEl.value = stringToCopy;
  tempEl.setAttribute('readonly', '');
  tempEl.style.position = 'absolute';
  tempEl.style.left = '-9999px';
  document.body.appendChild(tempEl);
  tempEl.select();
  document.execCommand('copy');
  document.body.removeChild(tempEl);
};
