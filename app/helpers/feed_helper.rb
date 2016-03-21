# To be added: custom activity templates.

module FeedHelper

  def format_activity activity
    partial = "feed/activities/default"
    render partial: partial, locals: { activity: activity }
  end

  # Activities are by default associated with the performing user,
  # but in the console we have no current user.
  def link_activity_user activity
    return "[system]" unless activity.user
    activity.user.decorate.name_linking_to_email
  end

  def link_trackable_if_exists activity, label, path = nil
    if activity.trackable
      link_to label, path ? path : activity.trackable
    else
      label
    end
  end

  def activity_action_to_verb action
    { create: "added",
      update: "edited",
      destroy: "deleted",
    }[action.to_sym] || action.upcase

    # upcase to avoid blwing up and make sure missing
    # actions are readable but ugly.
  end

  def trackabe_type_to_human type
    type.titleize.downcase
  end
end
