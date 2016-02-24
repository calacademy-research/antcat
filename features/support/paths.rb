module NavigationHelpers
  def path_to page_name
    case page_name

    when /^the main page$/
      root_path

    when /^the admin page$/
      root_path + "admin"

    when /^the useradmin page$/
      root_path + "admin/users"

    when /^the changes page$/
      '/changes'

    when /^the unreviewed changes page$/
      '/changes/unreviewed'

    when /^the missing reference edit page for "([^"]*)"$/
      reference = MissingReference.find_by_citation $1
      "/missing_references/#{reference.id}/edit"

    when /^the missing references page$/
      '/missing_references'

    when /^the advanced search page$/
      advanced_search_path

    when /^the catalog (entry|page) for "([^"]*)"$/
      taxon = Taxon.find_by_name $2
      "/catalog/#{taxon.id}"
    when /^the catalog$/
      root_path

    when /^the edit page for "(.*)"$/
      "/taxa/#{Taxon.find_by_name($1).id}/edit"

    when /^the new taxon page$/
      "/taxa/new"

    when /^the create taxon page$/
      '/taxa'

    when /^the "Convert to subspecies" page for "([^"]*)"$/
      taxon = Taxon.find_by_name $1
      "/taxa/#{taxon.id}/convert_to_subspecies"

    when /^the new "Convert to subspecies" page for "([^"]*)"$/
      taxon = Taxon.find_by_name $1
      "/taxa/#{taxon.id}/convert_to_subspecies/new"

    when /^the references page$/
      references_path
    when /^the new references page$/
      latest_additions_references_path
    when /^the page for that reference$/
      reference_path(@reference || Reference.first)

    when /^the "journals index" page$/
      journals_path

    when /^the Merge Authors page$/
      merge_authors_path

    when /^the authors page$/
      authors_path

    when /^the author edit page for "(.*)"$/
      "/authors/#{Author.find_by_names($1).first.id}/edit"

    when /^the tooltips editing page$/
      "/tooltips"

    when /^the edit user page$/
      '/users/edit'
    when /^the forgot password page$/
      '/users/password/new'
    when /^the login (page|form)$/
      '/users/sign_in'
    when /^the sign ?up (page|form)$/
      '/users/sign_up'
    when /^the users page$/
      '/users'

    when /^the reference field test page, opened to the first reference$/
      "/widget_tests/reference_field_test?id=#{Reference.first.id}"
    when /^the reference field test page/
      '/widget_tests/reference_field_test'

    when /^the reference popup widget test page, opened to the first reference$/
      "/widget_tests/reference_popup_test?id=#{Reference.first.id}"
    when /^the reference popup widget test page$/
      '/widget_tests/reference_popup_test'

    when /^the taxt editor test page$/
      '/widget_tests/taxt_editor_test'
    when /^the name popup test page$/
      '/widget_tests/name_popup_test'
    when /^the name field test page for a name$/
      "/widget_tests/name_field_test?id=#{Name.first.id}"
    when /^the name field test page$/
      '/widget_tests/name_field_test'
    when /^the tooltips test page$/
      '/widget_tests/tooltips_test'

    else
      raise "#{page_name} not found"
    end

  end
end

World NavigationHelpers
