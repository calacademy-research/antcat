# frozen_string_literal: true

class DatabaseScriptDecorator < Draper::Decorator
  GITHUB_MASTER_URL = "https://github.com/calacademy-research/antcat/blob/master"

  delegate :section, :tags, :filename_without_extension

  def self.format_tags tags
    html_spans = tags.map { |tag| h.content_tag :span, tag, class: tag_css_class(tag) }
    h.safe_join(html_spans, " ")
  end

  def format_tags
    tags_and_sections = ([section] + tags).compact - [DatabaseScripts::Tagging::MAIN_SECTION]
    self.class.format_tags(tags_and_sections)
  end

  def github_url
    "#{GITHUB_MASTER_URL}/#{DatabaseScript::SCRIPTS_DIR}/#{filename_without_extension}.rb"
  end

  def empty_status
    return '??' unless database_script.respond_to?(:results)
    return 'Excluded (slow/list)' if list_or_slow?

    if database_script.results.any?
      'Not empty'
    else
      'Empty'
    end
  end

  private

    def self.tag_css_class tag
      case tag
      when DatabaseScripts::Tagging::SLOW_TAG          then "warning-label"
      when DatabaseScripts::Tagging::VERY_SLOW_TAG     then "warning-label"
      when DatabaseScripts::Tagging::SLOW_RENDER_TAG   then "warning-label"
      when DatabaseScripts::Tagging::NEW_TAG           then "label"
      when DatabaseScripts::Tagging::UPDATED           then "label"
      when DatabaseScripts::Tagging::HAS_QUICK_FIX_TAG then "green-label"
      when DatabaseScripts::Tagging::HIGH_PRIORITY_TAG then "high-priority-label"
      else                                                  "white-label"
      end + " rounded-badge"
    end
    private_class_method :tag_css_class

    def list_or_slow?
      database_script.tags.include?('list') ||
        database_script.section == DatabaseScripts::Tagging::LIST_SECTION ||
        database_script.slow?
    end
end
