module CommentsHelper
  def link_comments_section commentable
    label = commentable.comment_threads.count
    link_to label, url_for(commentable) + "#comments"
  end
end
