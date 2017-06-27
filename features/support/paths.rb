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
      latest_additions_references_path
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
    when /^the author edit page for "(.*)"$/
      "/authors/#{Author.find_by_names($1).first.id}/edit"

    # Editor's Panel
    when /^the comments page$/
      "/comments"

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
