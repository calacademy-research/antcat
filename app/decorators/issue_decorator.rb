class IssueDecorator < Draper::Decorator
  delegate :open?

  def format_status
    open? ? "Open" : "Closed"
  end

  def format_status_css
    format_status.downcase
  end
end
