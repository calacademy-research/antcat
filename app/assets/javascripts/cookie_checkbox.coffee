# jQuery plugin for mirroring a checkbox's value i a cookie (named
# after the element's id). Also sets the initial value.

$.fn.checkboxCookify = (defaultVal=false) ->
  getValue = ->
    value = Cookies.get cookie
    if value is undefined
      defaultVal
    else
      value is "true"

  setCookie = => Cookies.set cookie, @is(":checked")

  setupCheckbox = =>
    @attr "checked", getValue()
    setCookie()
    @change => setCookie() # set click handler

  cookie = @attr "id"
  setupCheckbox()
