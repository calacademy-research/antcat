# jQuery plugin for mirroring a checkbox's value i a cookie (named
# after the element's id). Also sets the initial value.

$.fn.checkboxCookify = (defaultVal=false) ->
  getCookie = ->
    value = Cookies.get(cookie)
    if value is undefined
      defaultVal
    else
      value is "true"

  setCookie = => Cookies.set cookie, @is(":checked")

  cookie = @attr "id"

  # init
  @attr "checked", getCookie()
  setCookie()

  # click handler
  @change => setCookie()
