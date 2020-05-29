# frozen_string_literal: true

module PaperTrail
  class VersionDecorator < Draper::Decorator
    delegate :item_type, :item_id, :activity

    def revision_history_link
      return unless (url = RevisionHistoryPath[item_type, item_id])
      h.link_to "History", url, class: "btn-normal btn-tiny"
    end

    def activity_link
      return unless activity
      helpers.link_to 'Activity', activity, class: "btn-normal btn-tiny"
    end
  end
end
