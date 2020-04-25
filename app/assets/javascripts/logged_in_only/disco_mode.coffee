TOGGLE_BUTTON = "#toggle-disco-mode-js-hook"

$ ->
  discoMode = new DiscoMode()
  $(TOGGLE_BUTTON).css('display', 'inline-block') # Hidden initially due to FoUC link text.

  $(TOGGLE_BUTTON).click (event) ->
    event.preventDefault()
    discoMode.toggle()

class DiscoMode
  LOCAL_STORAGE_KEY = 'discoMode'
  CONTAINER = "body"

  COLOR_CODED_CATALOG_LINKS_CLASS = "color-coded-catalog-links"
  AFTER_LABELS_CLASS = "color-coded-catalog-links-after-labels"
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

  _isEnabledInState: -> $(CONTAINER).hasClass(COLOR_CODED_CATALOG_LINKS_CLASS)
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

  _showLinkColors: -> $(CONTAINER).addClass([COLOR_CODED_CATALOG_LINKS_CLASS, AFTER_LABELS_CLASS])
  _hideLinkColors: -> $(CONTAINER).removeClass([COLOR_CODED_CATALOG_LINKS_CLASS, AFTER_LABELS_CLASS])

  _showFireworks: -> $(CONTAINER).addClass(SHOW_FIREWORKS_CLASS)
  _hideFireworks: -> $(CONTAINER).removeClass(SHOW_FIREWORKS_CLASS)
