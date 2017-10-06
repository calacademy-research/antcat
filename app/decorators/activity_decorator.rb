class ActivityDecorator < Draper::Decorator
  delegate :user, :trackable_id, :trackable, :trackable_type,
    :parameters, :action, :edit_summary, :edit_summary?

  # Activities are by default associated with the performing user, but
  # in the console and other situations we may not have a current user.
  def link_user
    return "[system]" unless user
    user.decorate.user_page_link
  end

  def did_something
    partial = template_partial
    helpers.render partial: partial, locals: { activity: self }
  end

  def when
    sometime = helpers.time_ago_in_words activity.created_at
    "#{sometime} ago"
  end

  def anchor_path
    helpers.activities_path id: activity.id, anchor: "activity-#{activity.id}"
  end

  def revision_history_link
    url = RevisionHistoryPath[activity.trackable_type, activity.trackable_id]
    return unless url

    helpers.link_to "History", url, class: "btn-normal btn-tiny"
  end

  def icon
    css_classes = []
    css_classes << activity.trackable_type.underscore.downcase if activity.trackable_type
    css_classes << activity.action if activity.action
    css_classes << :automated_edit if activity.automated_edit?
    helpers.antcat_icon css_classes
  end

  def link_trackable_if_exists label = nil, path: nil
    label = "##{activity.trackable_id}" unless label

    if activity.trackable
      helpers.link_to label, path ? path : activity.trackable
    else
      label
    end
  end

  def trackabe_type_to_human
    activity.trackable_type.titleize.downcase
  end

  # TODO move non-general actions to the templates.
  def action_to_verb
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
    }[activity.action.to_sym] || activity.action.upcase

    # Default to the action name for missing actions (and upcase
    # upcase to make sure that they are readable but ugly).
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
    # 3) Catch `ActionView::MissingTemplate` in `#did_something` --> `_default.haml`
    def template_partial
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
      File.file? "./app/views/#{path}.haml"
    end
end