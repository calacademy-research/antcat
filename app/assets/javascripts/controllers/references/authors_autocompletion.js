// TODO something. This is also used for the reference form (author search only).

function setupAuthorAutocomplete(selector) {
  if (AntCat.testing)
    return

  selector.autocomplete({
    autoFocus: true,
    minLength: 3,
    source: function(request, response) {
      searchTerm = extractAuthorSearchTerm(this.element.val(), $(this.element).getSelection().start);
      if (searchTerm.length >= 3)
        $.getJSON('/authors/autocomplete', {term: searchTerm}, response);
      else
        response([]);
    },
    focus: function() {
      return false;
    },
    select: function(event, ui) {
      $this = $(this)
      value_and_position = insertAuthor(this.value, $this.getSelection().start, ui.item.value);
      this.value = value_and_position.string;
      $this.setCaretPos(value_and_position.position + 1)
      return false;
    }
  });
}

function extractAuthorSearchTerm(string, position) {
  if (string.length == 0)
    return "";
  var beforeCursor = string.substring(0, position);
  var lastSemicolon = beforeCursor.lastIndexOf(';');
  return $.trim(beforeCursor.substring(lastSemicolon + 1, position));
}

function insertAuthor(string, position, author) {
  if (string.length == 0)
    return {string: string, position: 0};

  var beforeCursor = string.substring(0, position);
  var priorSemicolon = beforeCursor.lastIndexOf(';');
  var beforePriorSemicolon = string.substring(0, priorSemicolon);
  if (beforePriorSemicolon.length > 0)
    beforePriorSemicolon += '; ';

  var afterCursor = string.substring(position, string.length);
  string = beforePriorSemicolon + author + '; ' + $.trim(afterCursor);

  afterCursor = string.substring(position, string.length);
  nextSemicolon = afterCursor.indexOf(';');
  position = nextSemicolon + position + 2;

  return {string: string, position: position};
}

function setupReferenceEditJournalAutocomplete(selector) {
  selector.autocomplete({
    autoFocus: true,
    source: "/journals/autocomplete",
    minLength: 3
  });
}

function setupReferenceEditPublisherAutocomplete(selector) {
  selector.autocomplete({
    autoFocus: true,
    source: "/publishers/autocomplete",
    minLength: 3
  });
}
