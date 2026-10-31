# frozen_string_literal: true

module Taxa
  module Operations
    class ForceParentChange
      include Service

      attr_private_initialize :taxon, :new_parent

      def call
        update_parent_and_save
      end

      private

        def update_parent_and_save
          # `requires_new`: the rollback below also undoes this change when the caller has a transaction open.
          taxon.transaction(requires_new: true) do
            taxon.update_parent new_parent
            # A failed save also rolls back what `update_parent` already saved (such as the new name).
            raise ActiveRecord::Rollback unless taxon.save

            true
          end
        end
    end
  end
end
