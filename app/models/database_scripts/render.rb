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
          case render_as
          when :as_taxon_table    then as_taxon_table
          when :as_protonym_table then as_protonym_table
          else raise 'could not render'
          end
        end
      end
    end

    private

      attr_reader :database_script
  end
end
