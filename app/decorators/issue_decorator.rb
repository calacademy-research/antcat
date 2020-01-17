class IssueDecorator < Draper::Decorator
  delegate :open?, :help_wanted?

  def format_status
    open? ? "Open" : "Closed"
  end

  def format_status_css
    format_status.downcase
  end

  def help_wanted_badge
    return unless help_wanted? && open?
    helpers.content_tag :span, "Help wanted!", class: "rounded-badge high-priority-label"
  end
end
