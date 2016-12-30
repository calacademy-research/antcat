module MergeAuthorsHelper
  def author_names_sentence names
    names.sort.map { |item| content_tag :span, item }
      .to_sentence.html_safe
  end
end
