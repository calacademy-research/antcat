module TasksHelper
  def markdown text
    AntcatMarkdown.render text
  end

  def task_icon status
    antcat_icon "task", status
  end
end
