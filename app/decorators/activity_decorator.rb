# frozen_string_literal: true

class ActivityDecorator < Draper::Decorator
  # Don't show user who created other users' accounts.
  HIDE_USER_FOR_TRACKABLE_TYPES = ['User']
  EVENT_TO_VERB = {
    Activity::CREATE  => "added",
    Activity::UPDATE  => "edited",
    Activity::DESTROY => "deleted"
  }

  delegate :user, :trackable, :trackable_id, :trackable_type,
    :parameters, :event, :edit_summary, :edit_summary?

  def self.link_taxon_if_exists id, deleted_label: nil
    if (taxon = Taxon.find_by(id: id))
      CatalogFormatter.link_to_taxon(taxon)
    else
      deleted_label || "##{id} [deleted]"
    end
  end

  def self.link_protonym_if_exists id, deleted_label: nil
    if (protonym = Protonym.find_by(id: id))
      CatalogFormatter.link_to_protonym_with_terminal_taxa(protonym)
    else
      deleted_label || "##{id} [deleted]"
    end
  end

  def self.link_reference_if_exists id, deleted_label: nil
    if (reference = Reference.find_by(id: id))
      reference.decorate.link_to_reference
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

  def revision_history_link
    return unless (url = RevisionHistoryPath[activity.trackable_type, activity.trackable_id])
    h.link_to "History", url, class: "btn-default"
  end

  def icon
    if activity.automated_edit? # Give automated edits higher precedence.
      css_classes = [:automated_edit]
    else
      css_classes = []
      css_classes << activity.trackable_type.underscore.downcase if activity.trackable_type
      css_classes << activity.event if activity.event
    end

    h.antcat_icon css_classes
  end

  def link_trackable_if_exists label = nil, path: nil
    label ||= "##{activity.trackable_id}"

    if activity.trackable
      h.link_to(label, (path || activity.trackable))
    else
      event == Activity::DESTROY ? label : (label + ' [deleted]')
    end
  end

  def link_taxon_trackable_if_exists id = trackable_id, deleted_label: nil
    self.class.link_taxon_if_exists(id, deleted_label: deleted_label)
  end

  def link_protonym_trackable_if_exists id = trackable_id, deleted_label: nil
    self.class.link_protonym_if_exists(id, deleted_label: deleted_label)
  end

  def link_reference_trackable_if_exists id = trackable_id, deleted_label: nil
    self.class.link_reference_if_exists(id, deleted_label: deleted_label)
  end

  # NOTE: Missing events are upcased to make sure they are ugly.
  def event_to_verb
    EVENT_TO_VERB[activity.event] || activity.event.upcase
  end

  def locked_or_deleted_user_registration?
    return false unless trackable_type == "User"
    trackable.locked? || trackable.deleted?
  end

  private

    def template_partial
      ActivityTemplatePartial[event: activity.event, trackable_type: activity.trackable_type]
    end
end
