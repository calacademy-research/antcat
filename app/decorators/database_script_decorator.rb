# frozen_string_literal: true

class DatabaseScriptDecorator < Draper::Decorator
  GITHUB_MASTER_BASE_URL = "#{Settings.github.repo_url}/blob/master"
  TAG_CSS_CLASSES = {
    DatabaseScripts::Tagging::SLOW_TAG          => "badge-danger",
    DatabaseScripts::Tagging::VERY_SLOW_TAG     => "badge-danger",
    DatabaseScripts::Tagging::SLOW_RENDER_TAG   => "badge-danger",
    DatabaseScripts::Tagging::NEW_TAG           => "badge-blue",
    DatabaseScripts::Tagging::UPDATED_TAG       => "badge-blue",
    DatabaseScripts::Tagging::HAS_QUICK_FIX_TAG => "badge-green",
    DatabaseScripts::Tagging::HAS_SCRIPT_TAG    => "badge-green",
    DatabaseScripts::Tagging::HIGH_PRIORITY_TAG => "badge-orange"
  }

  delegate :section, :tags, :basename

  def self.format_tags tags
    html_spans = tags.map do |tag|
      h.tag.span tag, class: [TAG_CSS_CLASSES[tag] || "badge-white"]
    end
    h.safe_join(html_spans, " ")
  end

  def self.format_linked_tags tags
    html_spans = tags.map do |tag|
      h.link_to tag, h.database_scripts_path(tag: tag), class: [TAG_CSS_CLASSES[tag] || "badge-white"]
    end
    h.safe_join(html_spans, " ")
  end

  def undecorate
    database_script
  end

  def format_tags
    self.class.format_tags(tags)
  end

  def format_linked_tags
    self.class.format_linked_tags(tags)
  end

  def soft_validated?
    database_script.class.in?(::DbScriptSoftValidations::ALL_DATABASE_SCRIPTS_TO_CHECK)
  end

  def slow?
    tags.include?(DatabaseScripts::Tagging::SLOW_TAG) || tags.include?(DatabaseScripts::Tagging::VERY_SLOW_TAG)
  end

  def regression_test?
    section == DatabaseScripts::Tagging::REGRESSION_TEST_SECTION
  end

  def github_url
    "#{GITHUB_MASTER_BASE_URL}/#{DatabaseScript::SCRIPTS_DIR}/#{basename}.rb"
  end

  def empty?
    empty_status == DatabaseScripts::EmptyStatus::NOT_EMPTY
  end

  def empty_status
    @_empty_status ||= DatabaseScripts::EmptyStatus[database_script]
  end

  def empty_status_css
    return unless section == DatabaseScripts::Tagging::REGRESSION_TEST_SECTION

    if empty?
      'bold-warning'
    end
  end
end
