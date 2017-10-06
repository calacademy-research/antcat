class ReferenceSection < ActiveRecord::Base
  include Trackable
  include PrimitiveSearch
  include RevisionsCanBeCompared

  attr_accessible :taxon_id, :title_taxt, :subtitle_taxt, :references_taxt,:position, :taxon

  belongs_to :taxon

  before_save { CleanNewlines.clean_newlines self, :subtitle_taxt, :references_taxt }

  acts_as_list scope: :taxon
  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  has_primitive_search where: ->(search_type) { <<-SQL.squish }
      title_taxt #{search_type} :q
        OR references_taxt #{search_type} :q
        OR subtitle_taxt #{search_type} :q
    SQL
  tracked on: :mixin_create_activity_only, parameters: proc { { taxon_id: taxon_id } }
end
