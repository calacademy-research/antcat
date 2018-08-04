module NavigationHelpers
  def path_to page_name
    case page_name

    when /^the main page$/
      root_path

    # Admin
    when /^the admin page$/
      "/admin"
    when /^the useradmin page$/
      "/admin/users"

    # Changes
    when /^the changes page$/
      '/changes'
    when /^the unreviewed changes page$/
      '/changes/unreviewed'

    # Catalog
    when /^the advanced search page$/
      catalog_search_path

    when /^the catalog (entry|page) for "([^"]*)"$/
      taxon = Taxon.find_by_name $2
      "/catalog/#{taxon.id}"
    when /^the catalog$/
      root_path

    # Editing (catalog)
    when /^the edit page for "(.*)"$/
      "/taxa/#{Taxon.find_by_name($1).id}/edit"
    when /^the new taxon page$/
      "/taxa/new"

    when /^the "Convert to subspecies" page for "([^"]*)"$/
      taxon = Taxon.find_by_name $1
      "/taxa/#{taxon.id}/convert_to_subspecies"
    when /^the new "Convert to subspecies" page for "([^"]*)"$/
      taxon = Taxon.find_by_name $1
      "/taxa/#{taxon.id}/convert_to_subspecies/new"

    # References, authors, etc
    when /^the references page$/
      references_path
    when /^the latest reference additions page$/
      references_latest_additions_path
    when /^the page for that reference$/
      reference_path(@reference || Reference.first)
    when /^the page of the most recent reference$/
      reference_path(Reference.last)
    when /^the edit page for the most recent reference$/
      edit_reference_path(Reference.last)

    when /^the merge authors page$/
      merge_authors_path
    when /^the authors page$/
      authors_path
    when /^the author page for "(.*)"$/
      "/authors/#{Author.find_by_names($1).first.id}"

    # Editor's Panel
    when /^the Editor's Panel$/
      "/panel"

    when /^the comments page$/
      "/comments"

    when /^the institutions page$/
      "/institutions"

    when /^my notifications page$/
      "/notifications"

    when /^the database scripts page$/
      "/database_scripts"

    when /^the site notices page$/
      "/site_notices"

    when /^the tooltips editing page$/
      "/tooltips"

    when /^the activity feed$/
      "/activities"

    when /^the versions page$/
      "/panel/versions"

    when /^the open issues page$/
      "/issues"
    when /^the issue page for "([^"]*)"$/
      issue = Issue.find_by(title: $1)
      "/issues/#{issue.id}"
    when /^the most recent issue$/
      "/issues/#{Issue.last.id}"
    when /^the new issue page$/
      "/issues/new"

    when /^the feedback index$/
      "/feedback"
    when /^the most recent feedback item$/
      "/feedback/#{Feedback.last.id}"

    # Reference sections and taxon history items
    when /^the reference sections page$/
      "/reference_sections"
    when /^the page of the most recent reference section$/
      reference_section_path(ReferenceSection.last)
    when /^the taxon history items page$/
      "/taxon_history_items"
    when /^the page of the most recent history item$/
      taxon_history_item_path(TaxonHistoryItem.last)

    # User
    when /^the user page for "([^"]*)"$/
      user = User.find_by name: $1
      "/users/#{user.id}"
    when /^the login page$/
      '/users/sign_in'
    when /^the sign up page$/
      '/users/sign_up'

    when /^the users page$/
      '/users'
    when /^the user emails list$/
      '/users/emails'

    # Widget test pages
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
