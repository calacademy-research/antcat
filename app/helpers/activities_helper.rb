# TODO rename anything feed --> activity.

module ActivitiesHelper
  def highlight_activity_link activity
    url = activities_path id: activity.id, anchor: "activity-#{activity.id}"
    link_to "(link)", url
  end

  def format_activity activity
    partial = partial_for_activity activity
    render partial: partial, locals: { activity: activity }
  end

  # Activities are by default associated with the performing user, but
  # in the console and other situations we may not have a current user.
  def link_activity_user activity
    return "[system]" unless activity.user
    activity.user.decorate.user_page_link
  end

  def link_trackable_if_exists activity, label = nil, path: nil
    label = "##{activity.trackable_id}" unless label

    if activity.trackable
      link_to label, path ? path : activity.trackable
    else
      label
    end
  end

  # TODO move non-general actions to the templates
  def activity_action_to_verb action
    { create: "added",
      update: "edited",
      destroy: "deleted",

      restart_reviewing: "restarted reviewing",
      finish_reviewing: "finished reviewing",
      start_reviewing: "started reviewing",

      approve_change: "approved",
      undo_change: "undid",

      close_issue: "closed",
      reopen_issue: "re-opened",

      close_feedback: "closed",
      reopen_feedback: "re-opened",
    }[action.to_sym] || action.upcase

    # Default to the action name for missing actions (and upcase
    # upcase to make sure that they are readable but ugly).
  end

  def trackabe_type_to_human type
    type.titleize.downcase
  end

  def activity_icon activity
    css_classes = []
    css_classes << activity.trackable_type.underscore.downcase if activity.trackable_type
    css_classes << activity.action if activity.action
    antcat_icon css_classes
  end

  private
    # Returns the partial's full path like this:
    # 1) The activity has no `#trackable_type`? --> `actions/_<action>`
    #    This happens when there's no trackable tied to the activity,
    #    for example the action "approve_all_changes".
    #
    # 2) There is a partial named `actions/_<action>.haml`? --> use that
    #
    # 3) There is a partial named `_<trackable_type>.haml`? --> use that
    #
    # 4) Else --> `_default.haml`
    #
    # TODO probably change to this:
    # 1) Activites with non-default actions (ie not create/update/destroy)
    #    --> `actions/_<action>.haml` (assume the template exists)
    #
    # 2) Else, just render --> "_<trackable_type>.haml"
    #
    # 3) Catch `ActionView::MissingTemplate` in `#format_activity` --> `_default.haml`
    def partial_for_activity activity
      templates_path = "activities/templates/"
      return "#{templates_path}actions/#{activity.action}" unless activity.trackable_type

      action_partial_name = activity.action
      action_partial_path = "#{templates_path}/actions/_#{action_partial_name}"

      type_partial_name = activity.trackable_type.underscore
      type_partial_path = "#{templates_path}_#{type_partial_name}"

      partial = if partial_exists? action_partial_path
                  "actions/#{action_partial_name}"
                elsif partial_exists? type_partial_path
                  type_partial_name
                else
                  "default"
                end
      "#{templates_path}#{partial}"
    end

    def partial_exists? path
      lookup_context.template_exists? path
    end
end
