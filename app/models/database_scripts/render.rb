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

        render
      end
    end

    private

      attr_reader :database_script
  end
end
