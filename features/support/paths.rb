# coding: UTF-8
module NavigationHelpers
  def path_to page_name
    case page_name
    when /the main page/
      root_path
    when /the references page/
      references_path
    when /the Bolton references page/
      bolton_references_path
    when /the page for that reference/
      reference_path(@reference || Reference.first)    
    when /the edit user page/
      '/users/edit'
    when /the "Edit journals" page/
      journals_path
    when /the Authors page/
      authors_path
    when /the catalog entry for "([^"]*)"/
      taxon = Taxon.find_by_name $1
      "/catalog/#{taxon.id}"
    when /the page for "([^"]*)"/
      taxon = Taxon.find_by_name $1
      "/catalog/#{taxon.id}"
    when /the catalog/
      catalog_path
    when /the forgot password page/
      '/users/password/new'
    when /the login page/
      '/users/sign_in'
    when /the reference picker widget test page, opened to the first reference/
      "/widget_tests/reference_picker_test?id=#{Reference.first.id}"
    when /the reference popup widget test page, opened to the first reference/
      "/widget_tests/reference_popup_test?id=#{Reference.first.id}"
    when /the reference picker widget test page/
      '/widget_tests/reference_picker_test'
    when /the reference popup widget test page/
      '/widget_tests/reference_popup_test'
    when /the reference field widget test page/
      '/widget_tests/reference_field_test'
    when /the taxt editor test page/
      '/widget_tests/taxt_editor_test'
    when /the name picker test page/
      '/widget_tests/name_picker_test'
    when /the name popup test page/
      '/widget_tests/name_popup_test'
    when /the name field test page for a name/
      "/widget_tests/name_field_test?id=#{Name.first.id}"
    when /the name field test page/
      '/widget_tests/name_field_test'
    when /the edit page for "(.*)"/
      "/taxa/#{Taxon.find_by_name($1).id}/edit"
    else
      raise "#{page_name} not found"
    end
  end
end

World NavigationHelpers
