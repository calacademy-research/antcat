# frozen_string_literal: true

module DatabaseScripts
  module Tagging
    SECTIONS = [
      UNGROUPED_SECTION = "ungrouped",
      MAIN_SECTION = "main",
      PENDING_AUTOMATION_ACTION_REQUIRED_SECTION = "pa-action-required",
      PENDING_AUTOMATION_NO_ACTION_REQUIRED_SECTION = "pa-no-action-required",
      LONG_RUNNING_SECTION = "long-running",
      NOT_NECESSARILY_INCORRECT_SECTION = "not-necessarily-incorrect",
      REVERSED_SECTION = "reversed",
      REGRESSION_TEST_SECTION = "regression-test",
      ORPHANED_RECORDS_SECTION = "orphaned-records",
      LIST_SECTION = "list",
      RESEARCH_SECTION = "research"
    ]
    SECTIONS_SORT_ORDER = SECTIONS
    TAGS = [
      SLOW_TAG = "slow",
      VERY_SLOW_TAG = "very-slow",
      SLOW_RENDER_TAG = "slow-render",
      NEW_TAG = "new!",
      UPDATED = "updated!",
      VALIDATED_TAG = "validated",
      HAS_QUICK_FIX_TAG = "has-quick-fix",
      HIGH_PRIORITY_TAG = "high-priority"
    ]
  end
end
