module CommentsHelper
  def link_comments_section commentable, suffix = ""
    total_comments = commentable.comment_threads.count
    link_to "#{total_comments}#{suffix}", url_for(commentable) + "#comments"
  end

  def link_comment comment, label
    link_to label, url_for(comment.commentable) + "#comment-#{comment.id}"
  end
end
