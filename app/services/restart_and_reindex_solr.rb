# frozen_string_literal: true

# HACK: Very "hmm", but OK as long as we're only running a single server app server instance.
class RestartAndReindexSolr
  include Service

  SCRIPT_PATH = "./script/solr/restart_and_reindex"

  def call
    return if Rails.env.test?

    $stdout.puts "Executing '#{SCRIPT_PATH}' in a new process..."
    Process.fork { system(restart_and_reindex_command) }
  end

  private

    def restart_and_reindex_command
      @_restart_and_reindex_command ||= "#{SCRIPT_PATH} #{Rails.env}"
    end
end
