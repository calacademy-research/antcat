# coding: UTF-8
module HtmlSelectorsHelpers
  def selector_for(locator)
    case locator

    when /the page/
      "html > body"

    when /the index/
      "#catalog .index"
    when /the (\w*) index/
      "#catalog .index .#{$1}"
    when /the content/
      "#catalog .antcat_taxon"
    when /the search results/
      "#search_results"

    when /the author panel/, /the first author panel/
      ".author_panel:first-of-type"
    when /the last author panel/
      ".author_panel:last-of-type"
    when /the second author panel/
      ".author_panel:nth-of-type(2)"
    when /another author panel/
      ".author_panel:last-of-type"

    when /the search box/
      "#q"

    when /the catalog search box/
      "#qq"

    when /the header/
      ".header"

    when /the first reference/
      first '.reference'

    when /the headline/
      '.headline'

    when /the name field/
      '.antcat_name_picker .display'

    when /"(.+)"/
      $1

    else
      raise "Can't find mapping from \"#{locator}\" to a selector"
    end

  end
end

World HtmlSelectorsHelpers
