# coding: UTF-8
module HtmlSelectorsHelpers
  # Maps a name to a selector. Used primarily by the
  #
  #   When /^(.+) within (.+)$/ do |step, scope|
  #
  # step definitions in web_steps.rb
  #
  def selector_for(locator)
    case locator

    when /the page/
      "html > body"

    when /the index/
      "#catalog .index"
    when /the (\w*) index/
      "#catalog .index .#{$1}"
    when /the content/
      "#catalog .content"
    when /the browser/
      "#browser"
    when /the browser header/
      "#browser .header"
    when /the search results/
      "#search_results"

    when /the author panel/, /the first author panel/
      ".author_panel:first-of-type"
    when /the last author panel/
      ".author_panel:last-of-type"

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #  when /the (notice|error|info) flash/
    #    ".flash.#{$1}"

    # You can also return an array to use a different selector
    # type, like:
    #
    #  when /the header/
    #    [:xpath, "//header"]

    # This allows you to provide a quoted selector as the scope
    # for "within" steps as was previously the default for the
    # web steps:
    when /"(.+)"/
      $1

    else
      raise "Can't find mapping from \"#{locator}\" to a selector"
    end
  end
end

World(HtmlSelectorsHelpers)
