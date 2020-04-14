# frozen_string_literal: true

module DatabaseScripts
  class Render
    def initialize database_script
      @database_script = database_script
    end

    def call
      database_script.instance_eval do
        singleton_class.include Rails.application.routes.url_helpers
        singleton_class.include ActionView::Helpers::UrlHelper

        extend DatabaseScripts::RenderHelpers

        if respond_to?(:render)
          render
        else
          extend ImplicitRender
          implicit_render
        end
      end
    end

    private

      attr_reader :database_script

      module ImplicitRender
        private

          def implicit_render
            case cached_results
            when ActiveRecord::Relation
              case cached_results.table.name # `#base_class` or `#klass` doesn't work for some reason.
              when "taxa" then as_taxon_table
              when "protonyms" then as_protonym_table
              when "references" then as_reference_list
              else "Error: cannot implicitly render ActiveRecord::Relation."
              end
            when Array
              return as_taxon_table if cached_results.first.is_a?(Taxon)
              return DatabaseScripts::Renderers::AsTable::FOUND_NO_DATABASE_ISSUES if cached_results.blank?
              "Error: cannot implicitly render results."
            else
              "Error: cannot implicitly render results."
            end
          end
      end
  end
end
