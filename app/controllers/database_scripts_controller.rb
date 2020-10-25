# frozen_string_literal: true

class DatabaseScriptsController < ApplicationController
  FLUSH_QUERY_CACHE_DEBUG = false

  before_action :authenticate_user!

  def index
    @total_number_of_database_scripts = DatabaseScript.all.size
    @grouped_database_scripts = DatabaseScript.all.group_by(&:section).
      sort_by { |section, _scripts| DatabaseScripts::Tagging::SECTIONS_SORT_ORDER.index(section) || 0 }
    @check_if_empty = params[:check_if_empty]
  end

  def show
    # :nocov:
    if FLUSH_QUERY_CACHE_DEBUG && Rails.env.development?
      ActiveRecord::Base.connection.execute('FLUSH QUERY CACHE;')
    end
    # :nocov:

    @database_script = find_database_script
    @decorated_database_script = @database_script.decorate
    @rendered, @render_duration = timed_render
  end

  private

    def find_database_script
      DatabaseScript.new_from_basename(params[:id])
    rescue DatabaseScript::ScriptNotFound
      raise ActionController::RoutingError, "Not Found"
    end

    # TODO: Probably move from controller and wrap in a renderer.
    def timed_render
      start = Time.current
      rendered = DatabaseScripts::Render.new(@database_script, render_options).call
      render_duration = Time.current - start

      [rendered, render_duration]
    end

    def render_options
      params.slice(:page)
    end
end
