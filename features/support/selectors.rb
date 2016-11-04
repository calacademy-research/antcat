module HtmlSelectorsHelpers
  def selector_for locator
    case locator

    # TODO change this or wherever the "default element" is defined to
    # "html > body #content" and use "I should see in the header" where required.
    # It would make error messages easier to read and steps easier to read/write
    # (less "I follow the first").
    when /the page/
      "html > body"

    when /the protonym/
      "#taxon_description .protonym_name"
    when /the type name/
      "#taxon_description .type"
    when /^the junior synonyms section$/
      '.junior_synonyms_section'
    when /^the senior synonyms section$/
      '.senior_synonyms_section'

    # TODO rename
    when /the index/
      "#taxon_browser"
    when /the (\w*) index/
      "#taxon_browser .#{$1}-test-hook"
    when /the content/
      "#taxon_description"
    when /the change history/
      "#taxon_description .change_history"

    when /the search results/
      "table"
    when /the search section/
      "#advanced_search"

    when /the author panel/, /the first author panel/
      find ".author_panel", match: :first
    when /the last author panel/
      all(".author_panel").last
    when /the second author panel/
      all(".author_panel")[1]
    when /another author panel/
      all(".author_panel").last

    when /the search box/
      "#q"

    when /the duplicate dialog box/
      ".dialog_duplicate"

    when /the catalog search box/
      "#qq"

    when /the header/
      "div.header"

    when /the headline/
      '.headline'

    when /the name field/
      '#test_name_field .display'

    when /the allow_blank name field/
      '#test_allow_blank_name_field .display'

    when /the new_or_homonym name field/
      '#test_new_or_homonym_name_field .display'

    when /the first row of author names/
      '#content table > tr:first'

    when /the users list/
      '#content table'

    when /"(.+)"/
      $1

    else
      raise "Can't find mapping from \"#{locator}\" to a selector"
    end
  end
end

World HtmlSelectorsHelpers

# To avoid typing `FactoryGirl.create` all the time (use `create`).
World FactoryGirl::Syntax::Methods
