class DatabaseScriptDecorator < Draper::Decorator
  GITHUB_MASTER_URL = "https://github.com/calacademy-research/antcat/blob/master"

  delegate_all

  def format_tags
    tags.map do |tag|
      helpers.content_tag :span, class: tag_css_class(tag) do
        helpers.raw tag.html_safe
      end
    end.join(" ").html_safe
  end

  def format_topic_areas
    topic_areas.join(", ").capitalize
  end

  def github_url
    scripts_path = DatabaseScript::SCRIPTS_DIR
    "#{GITHUB_MASTER_URL}/#{scripts_path}/#{filename_without_extension}.rb"
  end

  private
    def tag_css_class tag
      case tag
      when "slow"      then "warning-label"
      when "very-slow" then "warning-label"
      when "new!"      then "label"
      else                  "white-label"
      end
    end
end
