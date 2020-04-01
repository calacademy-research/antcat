# frozen_string_literal: true

class ActivityDecorator < Draper::Decorator
  # Don't show user who created other users' accounts.
  HIDE_USER_FOR_TRACKABLE_TYPES = ['User']

  # Returns the partial's full path like this:
  # 1) The activity has no `#trackable_type` --> `actions/_<action>` (like the action "approve_all_references")
  # 2) There is a partial named `actions/_<action>.haml` --> use that
  # 3) There is a partial named `_<trackable_type>.haml` --> use that
  # 4) Else --> `_default.haml`
  class ActivityTemplatePartial
    include Service

    TEMPLATES_PATH = "activities/templates/"

    def initialize action:, trackable_type:
      @action = action
      @trackable_type = trackable_type
    end

    def call
      return "#{TEMPLATES_PATH}actions/#{action}" unless trackable_type
      "#{TEMPLATES_PATH}#{partial}"
    end

    private

      attr_reader :action, :trackable_type

      def partial
        partial_for_action || partial_for_trackable_type || "default"
      end

      def partial_for_action
        return unless partial_exists?("#{TEMPLATES_PATH}/actions/_#{action}")
        "actions/#{action}"
      end

      def partial_for_trackable_type
        underscored_trackable_type = trackable_type.underscore
        return unless partial_exists?("#{TEMPLATES_PATH}_#{underscored_trackable_type}")
        underscored_trackable_type
      end

      def partial_exists? path
        File.file?("./app/views/#{path}.haml")
      end
  end

  delegate :user, :trackable, :trackable_id, :trackable_type,
    :parameters, :action, :edit_summary, :edit_summary?

  def link_user
    return if trackable_type.in?(HIDE_USER_FOR_TRACKABLE_TYPES) || user.nil?
    user.decorate.user_page_link
  end

  def did_something
    h.render template_partial, activity: self
  rescue StandardError
    "<code>error rendering Activity</code>".html_safe
  end

  def when
    h.time_ago_in_words(activity.created_at) + ' ago'
  end

  def anchor_path
    h.activities_path id: activity.id, anchor: "activity-#{activity.id}"
  end

  def revision_history_link
    # TODO: See if activities with a `trackable_type` but without a `trackable_id`
    # can still happen. `Activity.where(trackable_id: nil).where.not(trackable_type: nil).count # 5`
    return "<code>???</code>".html_safe if activity.trackable_type && activity.trackable_id.nil?
    return unless (url = RevisionHistoryPath[activity.trackable_type, activity.trackable_id])
    h.link_to "History", url, class: "btn-normal btn-tiny"
  end

  def icon
    if activity.automated_edit? # Give automated edits higher precedence.
      css_classes = [:automated_edit]
    else
      css_classes = []
      css_classes << activity.trackable_type.underscore.downcase if activity.trackable_type
      css_classes << activity.action if activity.action
    end

    h.antcat_icon css_classes
  end

  def link_trackable_if_exists label = nil, path: nil
    label ||= "##{activity.trackable_id}"

    if activity.trackable
      h.link_to(label, (path || activity.trackable))
    else
      action == 'destroy' ? label : (label + ' [deleted]')
    end
  end

  # NOTE: Missing actions are upcased to make sure they are ugly.
  def action_to_verb
    {
      create: "added",
      update: "edited",
      destroy: "deleted"
    }[activity.action.to_sym] || activity.action.upcase
  end

  private

    def template_partial
      ActivityTemplatePartial[action: activity.action, trackable_type: activity.trackable_type]
    end
end
