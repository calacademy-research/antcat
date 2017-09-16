class IssueDecorator < Draper::Decorator
  delegate :open?

  def format_status
    if open? then "Open" else "Closed" end
  end

  def format_status_css
    format_status.downcase
  end
end
