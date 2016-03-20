module TasksHelper

  def format_open_tasks tasks
    tasks.map do |task|
      link_to "task ##{task.id}", task
    end.to_sentence.html_safe
  end

  def markdown text
    AntcatMarkdown.render text
  end
end
