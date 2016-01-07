module HtmlSelectorsHelpers
  def selector_for(locator)
    case locator

      when /the page/
        "html > body"

      when /the protonym/
        "#catalog .protonym_name"
      when /the type name/
        "#catalog .type"
      when /^the junior synonyms section$/
        '.junior_synonyms_section'
      when /^the senior synonyms section$/
        '.senior_synonyms_section'

      when /the index/
        "#catalog .index"
      when /the species taxon index/
        "#catalog .index .species .taxon"
      when /the (\w*) index/
        "#catalog .index .#{$1}"
      when /the content/
        "#catalog .antcat_taxon"
      when /the change history/
        "#catalog .antcat_taxon .change_history"
      when /the search results/
        "#search_results"

      when /the search section/
        '.search_section'

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

      when /the duplicate dialog box/
        ".dialog_duplicate"

      when /the catalog search box/
        "#qq"

      when /the header/
        "div.header"

      when /the first reference/
        first '.reference'

      when /the headline/
        '.headline'

      when /the name field/
        '#test_name_field .display'

      when /the allow_blank name field/
        '#test_allow_blank_name_field .display'

      when /the new_or_homonym name field/
        '#test_new_or_homonym_name_field .display'

      when /the first row of author names/
        '#authors .author_row:first'

      when /the first row of missing references/
        '#missing_references .missing_reference:first'

      when /"(.+)"/
        $1

      else
        raise "Can't find mapping from \"#{locator}\" to a selector"
    end

  end
end

World HtmlSelectorsHelpers
