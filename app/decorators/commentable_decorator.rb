# frozen_string_literal: true

# Formats the comment count and the link to the comments of a record that takes comments (issue, feedback, site
# notice).
class CommentableDecorator < Draper::Decorator
  def link_existing_comments_section
    return unless commentable.comments.any?
    h.antcat_icon("comment") + comments_section_link
  end

  def comments_count_in_words
    h.pluralize commentable.comments.count, "comment"
  end

  private

    alias_method :commentable, :object

    def comments_section_link
      label = comments_count_in_words
      h.link_to label, h.polymorphic_path(commentable) + "#comments"
    end
end
