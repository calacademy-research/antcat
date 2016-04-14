module CommentsHelper
  def link_comments_section commentable
    label = commentable.comment_threads.count
    link_to label, url_for(commentable) + "#comments"
  end

  def link_comment comment, label
    link_to label, url_for(comment.commentable) + "#comment-#{comment.id}"
  end
end
