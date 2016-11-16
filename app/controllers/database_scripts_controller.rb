class DatabaseScriptsController < ApplicationController
  before_action :authenticate_editor, except: [:index]
  before_action :set_script, only: [:show, :source]

  def index
    @scripts = DatabaseScripts::DatabaseScript::all_scripts
  end

  def show
  end

  def source
  end

  private
    def set_script
      @script = DatabaseScripts::DatabaseScript::new_from_filename_without_extension params[:id]
    rescue DatabaseScripts::DatabaseScript::ScriptNotFound
      raise ActionController::RoutingError.new("Not Found")
    end
end
