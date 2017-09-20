# TODO implement pagination for lists inside scripts.

class DatabaseScriptsController < ApplicationController
  DEFAULT_EXPIRES_IN = Rails.env.development? ? 2.seconds : 24.hours

  before_action :authenticate_editor, except: :index
  before_action :set_script, only: [:show, :source, :regenerate]

  def index
    @regression_tests, @other_scripts = DatabaseScript.all.partition do |script|
      DatabaseScript::REGRESSION_TEST_TAG.in? script.tags
    end
  end

  def show
    respond_to do |format|
      format.html do
        @used_cached = used_cached?
        @cached_render, @render_duration = cached_render
      end

      format.csv do
        send_data @script.to_csv, filename: csv_filename
      end
    end
  end

  def source
  end

  def regenerate
    Rails.cache.delete @script.cache_key
    redirect_to database_script_path(@script)
  end

  private
    def set_script
      @script = DatabaseScript::new_from_filename_without_extension params[:id]
    rescue DatabaseScript::ScriptNotFound
      raise ActionController::RoutingError.new("Not Found")
    end

    def used_cached?
      Rails.cache.exist? @script.cache_key
    end

    def cached_render
      start = Time.now
      results = Rails.cache.fetch(@script, expires_in: expires_in) do
        @script.render
      end
      render_duration = Time.now - start

      [results, render_duration]
    end

    def expires_in
      if @script.tags.include? DatabaseScript::VERY_SLOW_TAG
        999.years
      else
        DEFAULT_EXPIRES_IN
      end
    end

    def csv_filename
      "antcat_org__#{@script.filename_without_extension}__#{Date.today}.csv"
    end
end
