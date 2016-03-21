module FeedHelper

  def format_activity activity
    partial = partial_for_activity activity
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

    # Default to the action name for missing actions (and upcase
    # upcase to make sure that they are readable but ugly).
  end

  def trackabe_type_to_human type
    type.titleize.downcase
  end

  private
    # Returns the partial's full path like this:
    #   there is a partial
    #   named `trackable_type`? --> activity.trackable_type
    #   else                    --> "default"
    def partial_for_activity activity
      partialized_name = activity.trackable_type.titleize.downcase
      activities_path = "feed/activities/"
      underscored_partial_path = "#{activities_path}_#{partialized_name}"

      partial = if lookup_context.template_exists? underscored_partial_path
                partialized_name
              else
                "default"
              end
      "#{activities_path}#{partial}"
    end
end
