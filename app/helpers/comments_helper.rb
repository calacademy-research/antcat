module CommentsHelper
  def has_comments? commentable
    !commentable.comments_count.zero?
  end

  def link_comments_section commentable
    label = comments_count_in_words commentable
    link_to label, url_for(commentable) + "#comments"
  end

  def comments_count_in_words commentable
    pluralize commentable.comments_count, "comment"
  end
end
