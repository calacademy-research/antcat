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
    when /the catalog/
      catalog_path
    when /the forgot password page/
      '/users/password/new'
    when /the login page/
      '/users/sign_in'
    when /the reference picker widget test page, opened to the first reference/
      "/widget_tests/reference_picker?id=#{Reference.first.id}"
    when /the reference picker widget test page/
      '/widget_tests/reference_picker'
    when /the reference field widget test page/
      '/widget_tests/reference_field'
    else
      raise "#{page_name} not found"
    end
  end
end

World NavigationHelpers
