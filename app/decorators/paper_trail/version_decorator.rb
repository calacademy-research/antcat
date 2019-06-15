module PaperTrail
  class VersionDecorator < Draper::Decorator
    delegate :item_type, :item_id

    def revision_history_link
      url = RevisionHistoryPath[item_type, item_id]
      return unless url

      h.link_to "History", url, class: "btn-normal btn-tiny"
    end
  end
end
