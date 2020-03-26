# frozen_string_literal: true

class NotificationDecorator < Draper::Decorator
  def link_comment label
    comment = notification.attached
    comment.decorate.link_comment label
  end

  def link_commentable
    comment = notification.attached
    link_item_or_deleted comment.commentable
  end

  def link_attached
    link_item_or_deleted notification.attached
  end

  private

    def link_item_or_deleted item
      return "[deleted]" unless item

      link = helpers.link_to item_link_label(item), item
      "#{item_type(item)} #{link}".html_safe
    end

    def item_link_label item
      case item
      when Issue      then item.title.to_s
      when SiteNotice then item.title.to_s
      when Feedback   then "##{item.id}"
      end
    end

    def item_type item
      item.class.name.titleize.downcase
    end
end
