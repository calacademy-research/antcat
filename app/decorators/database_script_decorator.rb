# frozen_string_literal: true

class DatabaseScriptDecorator < Draper::Decorator
  GITHUB_MASTER_BASE_URL = "https://github.com/calacademy-research/antcat/blob/master"
  TAG_CSS_CLASSES = {
    DatabaseScripts::Tagging::SLOW_TAG          => "warning-label",
    DatabaseScripts::Tagging::VERY_SLOW_TAG     => "warning-label",
    DatabaseScripts::Tagging::SLOW_RENDER_TAG   => "warning-label",
    DatabaseScripts::Tagging::NEW_TAG           => "label",
    DatabaseScripts::Tagging::UPDATED_TAG       => "label",
    DatabaseScripts::Tagging::HAS_QUICK_FIX_TAG => "green-label",
    DatabaseScripts::Tagging::HIGH_PRIORITY_TAG => "high-priority-label"
  }

  delegate :section, :tags, :basename

  def self.format_tags tags
    html_spans = tags.map do |tag|
      h.tag.span tag, class: [TAG_CSS_CLASSES[tag] || "white-label"] + ["rounded-badge"]
    end
    h.safe_join(html_spans, " ")
  end

  def format_tags
    tags_and_sections = ([section] + tags).compact - [DatabaseScripts::Tagging::MAIN_SECTION]
    self.class.format_tags(tags_and_sections)
  end

  def soft_validated?
    database_script.class.in?(SoftValidations::ALL_DATABASE_SCRIPTS_TO_CHECK)
  end

  def fix_random?
    database_script.class.in?(Catalog::FixRandomController::DATABASE_SCRIPTS_TO_CHECK)
  end

  def slow?
    tags.include?(DatabaseScripts::Tagging::SLOW_TAG) || tags.include?(DatabaseScripts::Tagging::VERY_SLOW_TAG)
  end

  def github_url
    "#{GITHUB_MASTER_BASE_URL}/#{DatabaseScript::SCRIPTS_DIR}/#{basename}.rb"
  end

  def empty_status
    DatabaseScripts::EmptyStatus[database_script]
  end
end
