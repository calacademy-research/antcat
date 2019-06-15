module Taxa
  module Operations
    class ForceParentChange
      include Service

      def initialize taxon, new_parent
        @taxon = taxon
        @new_parent = new_parent
      end

      def call
        update_parent_and_save
      end

      private

        attr_reader :taxon, :new_parent

        def update_parent_and_save
          taxon.transaction do
            UndoTracker.setup_change taxon, :update

            taxon.update_parent new_parent
            taxon.save
          end
        end
    end
  end
end
