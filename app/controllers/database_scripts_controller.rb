# frozen_string_literal: true

class DatabaseScriptsController < ApplicationController
  FLUSH_QUERY_CACHE_DEBUG = false
  # TODO: Move to `DatabaseScriptsPresenter`.
  INDEX_VIEW_OPTIONS = [
    CHECK_IF_EMPTY = 'check_if_empty',
    NON_EMPTY_REGRESSION_TESTS = 'non_empty_regression_tests'
  ]

  before_action :authenticate_user!

  def index
    @total_number_of_database_scripts = database_scripts_scope.size
    @grouped_database_scripts = grouped_database_scripts
    @check_if_empty = check_if_empty?
    @database_scripts_presenter = DatabaseScriptsPresenter.new
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

    def grouped_database_scripts
      database_scripts_scope.group_by(&:section).
        sort_by { |section, _scripts| DatabaseScripts::Tagging::SECTIONS_SORT_ORDER.index(section) || 0 }
    end

    # TODO: Unify `params[:view]` and `params[:tag]`.
    def database_scripts_scope
      @_database_scripts_scope ||= if params[:view] == NON_EMPTY_REGRESSION_TESTS
                                     DatabaseScript.non_empty_regression_tests
                                   elsif (tag = params[:tag])
                                     DatabaseScript.with_tag(tag)
                                   else
                                     DatabaseScript.all
                                   end
    end

    def find_database_script
      DatabaseScript.new_from_basename(params[:id])
    rescue DatabaseScript::ScriptNotFound
      raise ActionController::RoutingError, "Not Found"
    end

    def check_if_empty?
      params[:view].in?([CHECK_IF_EMPTY, NON_EMPTY_REGRESSION_TESTS])
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
