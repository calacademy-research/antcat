# TODO implement pagination for lists inside scripts.

class DatabaseScriptsController < ApplicationController
  before_action :ensure_can_edit_catalog, except: :index
  before_action :set_script, only: [:show, :source]

  def index
    @regression_tests, @other_scripts = DatabaseScript.all.partition do |script|
      DatabaseScript::REGRESSION_TEST_TAG.in? script.tags
    end
  end

  def show
    respond_to do |format|
      format.html do
        @rendered, @render_duration = timed_render
      end

      format.csv do
        send_data @script.to_csv, filename: csv_filename
      end
    end
  end

  def source
  end

  private

    def set_script
      @script = DatabaseScript.new_from_filename_without_extension params[:id]
    rescue DatabaseScript::ScriptNotFound
      raise ActionController::RoutingError, "Not Found"
    end

    def timed_render
      start = Time.current
      rendered = @script.render
      render_duration = Time.current - start

      [rendered, render_duration]
    end

    def csv_filename
      "antcat_org__#{@script.filename_without_extension}__#{Time.zone.today}.csv"
    end
end
