class DatabaseScripts::Scripts::CheckReferenceUrls
  include DatabaseScripts::DatabaseScript
  include DatabaseScripts::Renderers::CaptureStdoutFromRakeTask

  def render
    return dev_only_notice unless Rails.env.development?
    render!
  end

  private
    def render!
      render_captured_stdout_from_rake_task "antcat:references:check_urls"
    end

    def dev_only_notice
      plaintext <<-MESSAGE
This script can only be run in the development environment.
It calls `rake antcat:references:check_urls`, which takes about a minute to run.

The output looks something like this:
  12277 processed in 1 min 381.08/sec
  5289 (43%) with documents
  0 (0%) of those with documents, not found
MESSAGE
    end
end

__END__
description: Experimentally capturing output from Rake tasks.
tags: [new!, very-slow, dev-only, rake-task]
topic_areas: [references]
