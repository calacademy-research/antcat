module CommentsHelper
  def link_comments_section commentable
    count = commentable.comments_count
    label = "#{count} #{"comment".pluralize(count)}"
    link_to label, url_for(commentable) + "#comments"
  end

  def link_comment comment, label
    link_to label, url_for(comment.commentable) + "#comment-#{comment.id}"
  end
end
