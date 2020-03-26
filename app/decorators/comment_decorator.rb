# frozen_string_literal: true

class CommentDecorator < Draper::Decorator
  def link_comment label
    return "commented" unless comment.try :commentable
    helpers.link_to label, commentable_anchor_link
  end

  def truncated_for_tables
    truncated = helpers.truncate comment.body, length: 80, separator: " "
    stripped = helpers.strip_tags truncated
    Markdowns::ParseAntcatHooks[stripped].html_safe
  end

  private

    def commentable_anchor_link
      helpers.polymorphic_path comment.commentable, anchor: "comment-#{comment.id}"
    end
end
