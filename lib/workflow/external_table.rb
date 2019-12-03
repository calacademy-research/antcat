module Workflow
  module ExternalTable
    module InstanceMethods
      def load_workflow_state
        taxon_state.review_state
      end

      def persist_workflow_state new_value
        taxon_state.review_state = new_value
        taxon_state.save!
      end

      private

        def write_initial_state
          build_taxon_state review_state: TaxonState::WAITING unless taxon_state
          taxon_state.review_state = current_state.to_s
          taxon_state.save!
        end
    end

    def self.included klass
      klass.include InstanceMethods
    end
  end
end
