# frozen_string_literal: true

class ActivityDecorator < Draper::Decorator
  # Don't show user who created other users' accounts.
  HIDE_USER_FOR_TRACKABLE_TYPES = ['User']

  delegate :user, :trackable, :trackable_id, :trackable_type,
    :parameters, :action, :edit_summary, :edit_summary?

  def self.link_taxon_if_exists id, deleted_label: nil
    if (taxon = Taxon.find_by(id: id))
      taxon.link_to_taxon
    else
      deleted_label || "##{id} [deleted]"
    end
  end

  def link_user
    return if trackable_type.in?(HIDE_USER_FOR_TRACKABLE_TYPES) || user.nil?
    user.decorate.user_page_link
  end

  def did_something
    h.render template_partial, activity: self
  end

  def when
    h.time_ago_in_words(activity.created_at) + ' ago'
  end

  def css_anchor_id
    "activity-#{activity.id}"
  end

  def revision_history_link
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

  def link_taxon_trackable_if_exists id = trackable_id, deleted_label: nil
    self.class.link_taxon_if_exists(id, deleted_label: deleted_label)
  end

  # NOTE: Missing actions are upcased to make sure they are ugly.
  def action_to_verb
    {
      create: "added",
      update: "edited",
      destroy: "deleted"
    }[activity.action.to_sym] || activity.action.upcase
  end

  def locked_or_deleted_user_registration?
    return false unless trackable_type == "User"
    trackable.locked? || trackable.deleted?
  end

  private

    def template_partial
      ActivityTemplatePartial[action: activity.action, trackable_type: activity.trackable_type]
    end
end
