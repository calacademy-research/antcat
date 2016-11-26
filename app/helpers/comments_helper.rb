module CommentsHelper
  def link_comments_section commentable
    label = comments_count_in_words commentable
    link_to label, url_for(commentable) + "#comments"
  end

  def comments_count_in_words commentable
    pluralize commentable.comments_count, "comment"
  end

  # TODO default `label` to "commented"
  def link_comment comment, label
    return "commented" unless comment.try :commentable
    link_to label, url_for(comment.commentable) + "#comment-#{comment.id}"
  end

  def truncated_comment_for_tables comment
    truncated = truncate comment.body, length: 80, separator: " "
    stripped = strip_tags truncated
    antcat_markdown_only(stripped).html_safe
  end
end
