module HtmlSelectorsHelpers
  def selector_for locator
    case locator

    # TODO: Change this or wherever the "default element" is defined to
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
    when /the catalog search box/
      "#qq"
    when /the search results/
      "table"

    # Editor's Panel.
    when /the feed/
      'table.activities'

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
