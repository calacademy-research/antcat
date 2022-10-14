# frozen_string_literal: true

module DatabaseScripts
  module Tagging
    SECTIONS = [
      UNGROUPED_SECTION = "ungrouped",
      MISC_SECTION = "misc",
      MISSING_TAGS_SECTION = "missing-tags",
      DISAGREEING_HISTORY_SECTION = "disagreeing-history",
      CODE_CHANGES_REQUIRED_SECTION = "code-changes-required",
      PENDING_AUTOMATION_ACTION_REQUIRED_SECTION = "pa-action-required",
      PENDING_AUTOMATION_NO_ACTION_REQUIRED_SECTION = "pa-no-action-required",
      REVERSED_SECTION = "reversed",
      REGRESSION_TEST_SECTION = "regression-test",
      ORPHANED_RECORDS_SECTION = "orphaned-records",
      LIST_SECTION = "list",
      RESEARCH_SECTION = "research"
    ]
    SECTIONS_SORT_ORDER = SECTIONS
    TAGS = [
      "authors",
      "combinations",
      CODE_CHANGES_REQUIRED_SECTION,
      "disagreeing-data",
      "disagreeing-hist",
      "future",
      "grab-bag",
      "has-reversed",
      HAS_QUICK_FIX_TAG = "has-quick-fix",
      HAS_SCRIPT_TAG = "has-script",
      HIGH_PRIORITY_TAG = "high-priority",
      "inline-taxt",
      LIST_SECTION,
      "names",
      NEW_TAG = "new!",
      "obsolete-combinations",
      "original-combinations",
      "pdfs",
      "postgres",
      "protonyms",
      "reference-sections",
      REGRESSION_TEST_SECTION,
      "references",
      "rel-hist",
      "replacement-names",
      SLOW_RENDER_TAG = "slow-render",
      SLOW_TAG = "slow",
      "stats",
      "synonyms",
      "taxa",
      "taxt-hist",
      "taxt/rel-hist",
      "types",
      UPDATED_TAG = "updated!",
      VERY_SLOW_TAG = "very-slow"
    ]
  end
end
