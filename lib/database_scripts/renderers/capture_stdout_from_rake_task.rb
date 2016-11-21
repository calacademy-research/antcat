# Experimental feature. Possibly stupid for more than one reason, and it may
# be easier to just convert suitable Rake tasks to DB scripts instead.
#
# As of writing, this is only used in one script, which is responsible for
# making sure it's only called in development.
#
# Must be included manually, for the above reasons.

module DatabaseScripts::Renderers::CaptureStdoutFromRakeTask
  def run_rake_task task
    raise "paranoia" unless task == "antcat:references:check_urls"

    `bundle exec rake #{task} SUPPRESS_DEV_MONKEY_PATCHES_NOTICE=yes`
  end

  def render_captured_stdout_from_rake_task task
    plaintext run_rake_task(task).uncolorize
  end
end
