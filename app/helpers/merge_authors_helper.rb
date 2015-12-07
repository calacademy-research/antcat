module MergeAuthorsHelper

  def conjuncted_list items, css_class
    items = items.flatten.uniq.map do |item|
      %{<span class="#{css_class}">}.html_safe + item + %{</span>}.html_safe
    end.sort
    items.to_sentence(last_word_connector: " and ").html_safe
  end

end
