// `hotwire_app.js` may also add to `window.AntCat` (deferred, so it runs after this file).
window.AntCat = window.AntCat || {}

AntCat.escapeRegExp = (string) => string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')

// For at.js. Super comlicated way of saying "allow spaces and some other characters".
// Based on https://github.com/ichord/At.js/blob/a627b5fcac22c35d52b7fb6d8a93181d2546f3c0/src/default.coffee#L46-L58
AntCat.allowSpacesWhileAutocompleting = (flag, subtext) => {
  // "c0-1ff" contains the range of weird diacrited letters starting at "À" and ending at "ǿ".
  // See http://qaz.wtf/u/show.cgi?show=c0-1ff&type=hex and https://unicode-table.com/en/#basic-latin
  const regexp = new RegExp(`${flag}([A-Za-z0-9()&_.,:\\u00c0-\\u01ff +-]*)$|${flag}([^\\x00-\\xff]*)$`, 'gi')

  const match = regexp.exec(subtext)
  if (match) {
    return match[2] || match[1]
  }
  return null
}

// Via https://stackoverflow.com/a/3966822
AntCat.getInputSelection = (el, onlyStartPosition = false) => {
  let start = 0
  let end = 0

  if (typeof el.selectionStart === 'number' && typeof el.selectionEnd === 'number') {
    start = el.selectionStart
    end = el.selectionEnd
  } else {
    // Legacy Internet Explorer.
    const range = document.selection.createRange()
    if (range && range.parentElement() === el) {
      const len = el.value.length
      const normalizedValue = el.value.replace(/\r\n/g, '\n')
      // Create a working TextRange that lives only in the input.
      const textInputRange = el.createTextRange()
      textInputRange.moveToBookmark(range.getBookmark())
      // Check if the start and end of the selection are at the very end
      // of the input, since moveStart/moveEnd doesn't return what we want
      // in those cases.
      const endRange = el.createTextRange()
      endRange.collapse(false)
      if (textInputRange.compareEndPoints('StartToEnd', endRange) > -1) {
        start = len
        end = len
      } else {
        start = -textInputRange.moveStart('character', -len)
        start += normalizedValue.slice(0, start).split('\n').length - 1
        if (textInputRange.compareEndPoints('EndToEnd', endRange) > -1) {
          end = len
        } else {
          end = -textInputRange.moveEnd('character', -len)
          end += normalizedValue.slice(0, end).split('\n').length - 1
        }
      }
    }
  }

  if (onlyStartPosition) return start

  return el.value.slice(start, end)
}
