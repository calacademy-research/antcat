TOGGLE_BUTTON = "#toggle-disco-mode-js-hook"

$ ->
  discoMode = new DiscoMode()
  $(TOGGLE_BUTTON).get(0).classList.remove('hidden') # Hidden initially due to FoUC link text.

  $(TOGGLE_BUTTON).click (event) ->
    event.preventDefault()
    discoMode.toggle()

class DiscoMode
  LOCAL_STORAGE_KEY = 'discoMode'
  CONTAINER = document.body

  COLOR_CODED_CATALOG_LINKS_CLASS = "color-coded-catalog-links"
  SHOW_FIREWORKS_CLASS = "show-fireworks"

  constructor: ->
    if @_isEnabledInCookies()
      @_enableDiscoMode()
    else
      @_disableDiscoMode()

  toggle: ->
    if @_isEnabledInState()
      @_disableDiscoMode()
    else
      @_enableDiscoMode()
      @_showFireworks()

  _isEnabledInState: -> CONTAINER.classList.contains(COLOR_CODED_CATALOG_LINKS_CLASS)
  _isEnabledInCookies: -> localStorage.getItem(LOCAL_STORAGE_KEY)
  _enableInCookies: -> localStorage.setItem(LOCAL_STORAGE_KEY, true)
  _disableInCookies: -> localStorage.removeItem(LOCAL_STORAGE_KEY)

  _enableDiscoMode: ->
    @_showLinkColors()
    $(TOGGLE_BUTTON).text "Leave the disco :("
    @_enableInCookies()

  _disableDiscoMode: ->
    @_hideLinkColors()
    $(TOGGLE_BUTTON).text "Go to the disco!"
    @_disableInCookies()
    @_hideFireworks()

  _showLinkColors: -> CONTAINER.classList.add(COLOR_CODED_CATALOG_LINKS_CLASS)
  _hideLinkColors: -> CONTAINER.classList.remove(COLOR_CODED_CATALOG_LINKS_CLASS)

  _showFireworks: -> CONTAINER.classList.add(SHOW_FIREWORKS_CLASS)
  _hideFireworks: -> CONTAINER.classList.remove(SHOW_FIREWORKS_CLASS)
