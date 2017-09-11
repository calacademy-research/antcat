class DatabaseScriptsController < ApplicationController
  DEFAULT_EXPIRES_IN = Rails.env.development? ? 2.seconds : 24.hours

  before_action :authenticate_editor, except: :index
  before_action :set_script, only: [:show, :source, :regenerate]

  def index
    @scripts = DatabaseScript.all
  end

  def show
    @used_cached = used_cached?
    @cached_render, @render_duration = cached_render
    @cached_at = cached_at
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

    # TODO improve.
    def cached_at
      entry = Rails.cache.send :read_entry, @script.cache_key, {}
      Time.at entry.instance_variable_get(:@created_at)
    end
end
