module RevisionsCanBeCompared
  extend ActiveSupport::Concern

  module ClassMethods
    def revision_comparer_for id, selected_id = nil
      RevisionComparer.new self, id, selected_id
    end
  end
end
