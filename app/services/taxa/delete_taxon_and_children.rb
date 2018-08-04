# TODO add `before_destroy :check_not_referenced`, but allow suppressing it.

module Taxa
  class DeleteTaxonAndChildren
    include Service

    def initialize taxon
      @taxon = taxon
    end

    def call
      delete_taxon_and_children
    end

    private

      attr_reader :taxon

      delegate :create_activity, to: :taxon

      def delete_taxon_and_children
        Feed.without_tracking do
          Taxon.transaction do
            UndoTracker.setup_change taxon, :delete
            delete_taxon_children taxon
            delete_with_state! taxon
          end
        end
        create_activity :destroy
      end

      def delete_with_state! taxon
        Taxon.transaction do
          # Bit of a hack; this is a new table which may lack the depth of other tables.
          # Creation doesn't add a record, so you can't "step back to" a valid version.
          # doing touch_with_version (creeate a fallback point) in the migration makes an
          # enourmous and unnecessary pile of these.
          taxon_state = taxon.taxon_state
          taxon_state.paper_trail.touch_with_version if taxon_state.versions.empty?

          taxon_state.deleted = true
          taxon_state.review_state = TaxonState::WAITING
          taxon_state.save
          taxon.destroy!
        end
      end

      def delete_taxon_children taxon
        taxon.children.each do |child|
          delete_with_state! child
          delete_taxon_children child
        end
      end
  end
end
