#https://github.com/fczbkk/css-selector-generator
class CssSelectorGenerator

  default_options:
# choose from 'tag', 'id', 'class', 'nthchild', 'attribute'
    selectors: ['id', 'class', 'tag', 'nthchild']

  constructor: (options = {}) ->
    @options = {}
    @setOptions @default_options
    @setOptions options

  setOptions: (options = {}) ->
    for key, val of options
      @options[key] = val if @default_options.hasOwnProperty key

  isElement: (element) ->
    !!(element?.nodeType is 1)

  getParents: (element) ->
    result = []
    if @isElement element
      current_element = element
      while @isElement current_element
        result.push current_element
        current_element = current_element.parentNode
    result

  getTagSelector: (element) ->
    element.tagName.toLowerCase()

# escapes special characters in class and ID selectors
  sanitizeItem: (item) ->
    characters = (item.split '').map (character) ->
# colon is valid character in an attribute, but has to be escaped before
# being used in a selector, because it would clash with the CSS syntax
      if character is ':'
        "\\#{':'.charCodeAt(0).toString(16).toUpperCase()} "
      else if /[ !"#$%&'()*+,./;<=>?@\[\\\]^`{|}~]/.test character
        "\\#{character}"
      else
        escape character
        .replace /\%/g, '\\'

    return characters.join ''


  getIdSelector: (element) ->
    id = element.getAttribute 'id'

    # ID must... exist, not to be empty and not to contain whitespace
    if (
# ...exist
      id? and
        # ...not be empty
        (id isnt '') and
        # ...not contain whitespace
        not (/\s/.exec id) and
        # ...not start with a number
        not (/^\d/.exec id)
    )
      sanitized_id = "##{@sanitizeItem id}"
      # ID must match single element
      if document.querySelectorAll(sanitized_id).length is 1
        return sanitized_id

    null

  getClassSelectors: (element) ->
    result = []
    class_string = element.getAttribute 'class'
    if class_string?
# remove multiple whitespaces
      class_string = class_string.replace /\s+/g, ' '
      # trim whitespace
      class_string = class_string.replace /^\s|\s$/g, ''
      if class_string isnt ''
        result = for item in class_string.split /\s+/
          ".#{@sanitizeItem item}"
    result

  getAttributeSelectors: (element) ->
    result = []
    blacklist = ['id', 'class']
    for attribute in element.attributes
      unless attribute.nodeName in blacklist
        result.push "[#{attribute.nodeName}=#{attribute.nodeValue}]"
    result

  getNthChildSelector: (element) ->
    parent_element = element.parentNode
    if parent_element?
      counter = 0
      siblings = parent_element.childNodes
      for sibling in siblings
        if @isElement sibling
          counter++
          return ":nth-child(#{counter})" if sibling is element
    null

  testSelector: (element, selector) ->
    is_unique = false
    if selector? and selector isnt ''
      result = element.ownerDocument.querySelectorAll selector
      is_unique = true if result.length is 1 and result[0] is element
    is_unique

  getAllSelectors: (element) ->
    result = t: null, i: null, c: null, a: null, n: null

    if 'tag' in @options.selectors
      result.t = @getTagSelector element

    if 'id' in @options.selectors
      result.i = @getIdSelector element

    if 'class' in @options.selectors
      result.c = @getClassSelectors element

    if 'attribute' in @options.selectors
      result.a = @getAttributeSelectors element

    if 'nthchild' in @options.selectors
      result.n = @getNthChildSelector element

    result


  testUniqueness: (element, selector) ->
    parent = element.parentNode
    found_elements = parent.querySelectorAll selector
    found_elements.length is 1 and found_elements[0] is element


# helper function that tests all combinations for uniqueness
  testCombinations: (element, items, tag) ->
    for item in @getCombinations items
      return item if @testUniqueness element, item

    # if tag selector is enabled, try attaching it
    if tag?
      for item in (items.map (item) -> tag + item)
        return item if @testUniqueness element, item

    return null


  getUniqueSelector: (element) ->
    selectors = @getAllSelectors element

    for selector_type in @options.selectors

      switch selector_type

# ID selector (no need to check for uniqueness)
        when 'id'
          if selectors.i?
            return selectors.i

# tag selector (should return unique for BODY)
        when 'tag'
          if selectors.t?
            return selectors.t if @testUniqueness element, selectors.t

# class selector
        when 'class'
          if selectors.c? and selectors.c.length isnt 0
            found_selector = @testCombinations element, selectors.c, selectors.t
            return found_selector if found_selector

# attribute selector
        when 'attribute'
          if selectors.a? and selectors.a.length isnt 0
            found_selector = @testCombinations element, selectors.a, selectors.t
            return found_selector if found_selector

# if anything else fails, return n-th child selector
        when 'nthchild'
          if selectors.n?
            return selectors.n

    return '*'


  getSelector: (element) ->
    all_selectors = []

    parents = @getParents element
    for item in parents
      selector = @getUniqueSelector item
      all_selectors.push selector if selector?

    selectors = []
    for item in all_selectors
      selectors.unshift item
      result = selectors.join ' > '
      return result if @testSelector element, result

    return null


  getCombinations: (items = []) ->
# first item must be empty (seed), it will be removed later
    result = [[]]

    for i in [0..items.length - 1]
      for j in [0..result.length - 1]
        result.push result[j].concat items[i]

    # remove first empty item (seed)
    result.shift()

    # sort results by length, we want the shortest selectors to win
    result = result.sort (a, b) -> a.length - b.length

    # collapse combinations and add prefix
    result = result.map (item) -> item.join ''

    result


if define?.amd
  define [], -> CssSelectorGenerator
else
  root = if exports? then exports else this
  root.CssSelectorGenerator = CssSelectorGenerator

$ ->
  $.ajax '/tooltips/enabled_selectors', success: (data) -> # TODO improve this
    tooltipsToInsert = data
    (new AntCat.SelectorTooltips).createTooltips tooltipsToInsert
    (new AntCat.Tooltipify).tooltipifyAll()


$ ->
  $.ajax '/tooltips/render_missing_tooltips', success: (data) ->
    # Find a plugin that does this
    # Temporarily dumped coffeescript for CssSelectorGenerator above this line for testing.
    # https://github.com/fczbkk/css-selector-generator-benchmark
    # https://github.com/autarc/optimal-select
    # https://github.com/fczbkk/css-selector-generator
    # TODO: make it so that if you cick an "edit" icon, if there's already a live tooltip, edit that one instead.
    # TODO: If the edit screen is reached by clicking one of these edit icons, a "save" should bring you back
    #       to the origin screen.
    selector_generator = new CssSelectorGenerator

    if data.show_missing_tooltips == true
      $('label, button, .ui-button').not('.display_button').each (index, element) =>
        selector = encodeURI(selector_generator.getSelector(element));
        $(element).after("""\
        <a class = "create_tooltip" href="/tooltips/new/?selector=""" + selector +
                        """ "> \
        <img class="help_icon tooltip " \
         title="Create tooltip" src="/assets/create_tip.png" alt="Help" /></a>\
         """)



  # Added to the global window object to make it callable from anywhere.
  window.testTooltipSelector = (new AntCat.TestTooltipSelector).testTooltipSelector

class AntCat.SelectorTooltips
  SELECTOR_TOOLTIP_CLASS = 'selector-tooltip'
  SELECTOR_TEST_TOOLTIP_CLASS = 'selector-test-tooltip'

  # Accepts an array of arrays in this format: [['jquery_selector', 'tooltip_text', 'id']]
  createTooltips: (tooltips) ->
    for tooltip in tooltips
      selector = tooltip[0]
      title = tooltip[1]
      id = tooltip[2]
      @createTooltip selector, title, id

  createTooltip: (selector, title, id, test_tooltip = false) =>
    disable_edit_link = false # TODO add this, currently it's not possible to disable

    iconElement = $(@_createIcon title, id)
    iconElement.addClass(SELECTOR_TEST_TOOLTIP_CLASS) if test_tooltip

    iconElement.insertAfter $(selector)

  removeAllSelectorTestTooltips: -> $(".#{SELECTOR_TEST_TOOLTIP_CLASS}").remove()

  _createIcon: (title, id) => # TODO move the link from this function
    """<a class="#{SELECTOR_TOOLTIP_CLASS}" href="/tooltips/#{id}">\
       <img class="help_icon tooltip #{SELECTOR_TOOLTIP_CLASS}" \
       title="#{title}" src="/assets/help.png" alt="Help" /></a>"""

class AntCat.Tooltipify
  # Wrapper function that formats the tooltips.
  #
  # `$('.tooltip').tooltip()` is built-into jQuery UI; it takes a selector
  # (class="tooltip" by convention), and "tooltipifies" all elements matching that selector;
  # whatever is in the `title` attribute on those elements is used as the tooltip text.
  tooltipifyAll: ->
    $('.tooltip').tooltip
      show: false # show immediately
      content: -> $(this).prop('title') # Without this, HTML is displayed as text.
      position:
        my: "left top"
        at: "right bottom"
      close: (event, ui) -> # Keep open if the tooltip is hovered.
        startHoverHandler = -> $(this).stop(true)
        stopHoverHandler = -> $(this).remove()
        ui.tooltip.hover startHoverHandler, stopHoverHandler

# For letting editors test selectors; works in all views where tooltips are enabled.
# It is only possible to test one selector at the time -- all other test tooltips
# are removed before inserting the new one.
#
# To test a selector, paste this snippet into your browser's JavaScript console:
#   testTooltipSelector('label[for="reference_title"]');
# A second and third arguments are optional (for the tooltip text and id):
#   testTooltipSelector('label[for="reference_title"]', "Wololoo", "9999");
#
# This method is exposed on the global window object in jQuery's .ready function.
class AntCat.TestTooltipSelector
  testTooltipSelector: (selector, title = 'test', id = '99999') ->
    engine = new AntCat.SelectorTooltips
    engine.removeAllSelectorTestTooltips()
    test_tooltip = true
    engine.createTooltip selector, title, id, test_tooltip
    (new AntCat.Tooltipify).tooltipifyAll()