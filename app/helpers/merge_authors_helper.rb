module MergeAuthorsHelper

  def conjuncted_list items, css_class
    items.flatten.uniq.map do |item|
      content_tag :span, item, class: css_class
    end.sort.to_sentence(last_word_connector: " and ").html_safe
  end

end
