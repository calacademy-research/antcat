class DatabaseScriptsController < ApplicationController
  EXPIRES_IN = Rails.env.development? ? 1.second : 24.hours

  before_action :authenticate_editor, except: [:index]
  before_action :set_script, only: [:show, :source, :regenerate]

  def index
    @scripts = DatabaseScript.all
  end

  def show
    @used_cached = used_cached? @script

    start = Time.now
    @cached_render = cached_render @script
    @render_duration = Time.now - start

    @cached_at = cached_at @script
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

    def used_cached? script
      Rails.cache.exist? script.cache_key
    end

    def cached_render script
      Rails.cache.fetch(script, expires_in: EXPIRES_IN) do
        script.render
      end
    end

    # TODO improve.
    def cached_at script
      entry = Rails.cache.send :read_entry, script.cache_key, {}
      Time.at entry.instance_variable_get(:@created_at)
    end
end
