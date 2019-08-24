class ActivityDecorator < Draper::Decorator
  TEMPLATES_PATH = "activities/templates/"

  delegate :user, :trackable_id, :trackable, :trackable_type,
    :parameters, :action, :edit_summary, :edit_summary?

  def link_user
    return '' unless user
    user.decorate.user_page_link
  end

  def did_something
    partial = template_partial
    helpers.render partial, activity: self
  rescue StandardError
    "<code>error rendering error Activity :(</code>".html_safe
  end

  def when
    helpers.time_ago_in_words(activity.created_at) + ' ago'
  end

  def anchor_path
    helpers.activities_path id: activity.id, anchor: "activity-#{activity.id}"
  end

  def revision_history_link
    url = RevisionHistoryPath[activity.trackable_type, activity.trackable_id]
    return unless url

    helpers.link_to "History", url, class: "btn-normal btn-tiny"
  rescue ActionController::UrlGenerationError
    "<code>???</code>".html_safe
  end

  def icon
    if activity.automated_edit? # Give automated edits higher precedence.
      css_classes = [:automated_edit]
    else
      css_classes = []
      css_classes << activity.trackable_type.underscore.downcase if activity.trackable_type
      css_classes << activity.action if activity.action
    end

    helpers.antcat_icon css_classes
  end

  def link_trackable_if_exists label = nil, path: nil
    label ||= "##{activity.trackable_id}"

    if activity.trackable
      helpers.link_to label, path || activity.trackable
    else
      label
    end
  end

  def trackabe_type_to_human
    activity.trackable_type.titleize.downcase
  end

  # Upcase missing actions to make sure they are ugly.
  def action_to_verb
    {
      create: "added",
      update: "edited",
      destroy: "deleted"
    }[activity.action.to_sym] || activity.action.upcase
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
    def template_partial
      return "#{TEMPLATES_PATH}actions/#{activity.action}" unless activity.trackable_type

      action_partial_name = activity.action
      action_partial_path = "#{TEMPLATES_PATH}/actions/_#{action_partial_name}"

      type_partial_name = activity.trackable_type.underscore
      type_partial_path = "#{TEMPLATES_PATH}_#{type_partial_name}"

      partial = if partial_exists? action_partial_path
                  "actions/#{action_partial_name}"
                elsif partial_exists? type_partial_path
                  type_partial_name
                else
                  "default"
                end
      "#{TEMPLATES_PATH}#{partial}"
    end

    def partial_exists? path
      File.file? "./app/views/#{path}.haml"
    end
end
