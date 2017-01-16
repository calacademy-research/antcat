# TODO DRY this, `FeedHelper` and all the activity partials.

module NotificationsHelper
  def link_commentable comment
    commentable = comment.try :commentable
    link_thing commentable
  end

  # TODO improve name...
  def link_thing thing
    return "[deleted]" unless thing

    link = link_to thing_link_label(thing), thing
    "#{thing_label_prefix(thing)} #{link}".html_safe
  end

  def thing_label_prefix thing
    thing.class.name.titleize.downcase
  end

  def thing_link_label thing
    case thing
    when Issue      then "#{thing.title}"
    when SiteNotice then "#{thing.title}"
    when Feedback   then "feedback ##{thing.id}"
    end
  end
end
