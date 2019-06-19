module HtmlSelectorsHelpers
  def selector_for locator
    case locator

    # TODO change this or wherever the "default element" is defined to
    # "html > body #content" and use "I should see in the header" where required.
    # It would make error messages easier to read and steps easier to read/write
    # (less "I follow the first").
    when /the page/
      "html > body"

    # Catalog.
    when /^the taxon browser$/
      "#taxon_browser"
    when /^the (\w*) taxon browser tab$/
      tab_title_target = find(:link, $1)[:href]
      tab_title_target
    when /the protonym/
      "#taxon_description .headline > span.name"
    when /the header/
      "div.header"
    when /the headline/
      '.headline'

    # Catalog search.
    when /the search box/
      "#q"
    when /the catalog search box/
      "#qq"
    when /the search results/
      "table"
    when /the search section/
      "#advanced_search"

    # Merge authors.
    when /the author panel/, /the first author panel/
      find ".author_panel", match: :first
    when /the last author panel/
      all(".author_panel").last
    when /the second author panel/
      all(".author_panel")[1]
    when /another author panel/
      all(".author_panel").last

    # Test pages.
    when /the name field/
      '#test_name_field .display'
    when /the new_or_homonym name field/
      '#test_new_or_homonym_name_field .display'

    when /the left side of the diff/
      all(".callout .diff")[0]
    when /the right side of the diff/
      all(".callout .diff")[1]

    when /"(.+)"/
      $1

    else
      raise %(Can't find mapping from "#{locator}" to a selector)
    end
  end
end

World HtmlSelectorsHelpers
World FactoryBot::Syntax::Methods # To avoid typing `FactoryBot.create`.
