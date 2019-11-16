module Taxa
  module Operations
    class ForceParentChange
      include Service

      def initialize taxon, new_parent, user:
        @taxon = taxon
        @new_parent = new_parent
        @user = user
      end

      def call
        update_parent_and_save
      end

      private

        attr_reader :taxon, :new_parent, :user

        def update_parent_and_save
          taxon.transaction do
            UndoTracker.setup_change taxon, :update, user: user

            taxon.update_parent new_parent
            taxon.save
          end
        end
    end
  end
end
