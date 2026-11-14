# frozen_string_literal: true

# Runs a database script's `render` to make its results page.
module DatabaseScripts
  class Render
    def initialize database_script, options = {}
      @database_script = database_script
      @options = options
    end

    def call
      database_script.instance_exec(options) do |options|
        singleton_class.include Rails.application.routes.url_helpers
        singleton_class.include ActionView::Helpers::UrlHelper

        extend DatabaseScripts::RenderHelpers

        render_with_options_or_default options
      end
    end

    private

      attr_reader :database_script, :options
  end
end
