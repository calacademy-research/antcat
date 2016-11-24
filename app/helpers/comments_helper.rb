module CommentsHelper
  def link_comments_section commentable
    label = pluralize commentable.comments_count, "comment"
    link_to label, url_for(commentable) + "#comments"
  end

  def link_comment comment, label
    link_to label, url_for(comment.commentable) + "#comment-#{comment.id}"
  end
end
