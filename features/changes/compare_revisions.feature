@feed @papertrail
Feature: Compare revisions
  As an editor of AntCat
  I want to browse previous revisions of items
  So I can see what has been changed

  Background:
    Given I log in as a catalog editor named "Archibald"

  # One big scenario for "reasons".
  @javascript
  Scenario: Comparing history item revisions
    Given there is a genus "Atta"

    # Added item.
    When I go to the edit page for "Atta"
    And I add a history item "initial content"
    And I wait
    And I go to the activity feed
    And I follow the first linked history item
    Then I should see "This item does not have any previous revisions"

    # Edited.
    When I go to the edit page for "Atta"
    And I update the history item to say "second revision content"
    And I go to the activity feed
    And I follow the first linked history item
    Then I should see "Current version"
    And I should see "second revision content"
    And I should not see "initial content"

    When I follow "prev"
    Then I should see "Difference between revisions"
    And I should see "initial content"

    # Deleted.
    When I go to the edit page for "Atta"
    And I click the history item
    And I will confirm on the next step
    And I delete the history item
    Then I should be on the edit page for "Atta"

    When I go to the activity feed
    And I follow the first linked history item
    Then I should see "Version before item was deleted"
    And I should see "second revision content"

    When I follow "cur"
    Then I should see "Difference between revisions"
    And I should see "initial content"

  Scenario: Comparing reference section revisions (testing added only)
    When I add a reference section for the feed
    And I go to the activity feed
    Then I should see "Archibald added the reference section" and no other feed items

    When I follow the first linked reference section
    Then I should see "This item does not have any previous revisions"

  @javascript
  Scenario: Comparing revisions with intermediate revisions
    Given there is a genus "Atta"
    And I go to the edit page for "Atta"
    And I add a history item "initial version"
    And I update the history item to say "second version"
    And I update the history item to say "last version"

    When I go to the activity feed
    And I follow the first linked history item
    And press "Compare selected revisions"
    Then I should see "second version" in the left side of the diff
    And I should see "last version" in the right side of the diff
    And I should not see "initial version"

    When I follow the second "cur"
    Then I should see "initial version" in the left side of the diff
    And I should see "last version" in the right side of the diff
    And I should not see "second version"

  Scenario: Comparing institution revisions
    When I go to the institutions page
    And I follow "New"
    And I fill in "institution_abbreviation" with "CASC"
    And I fill in "institution_name" with "California Academy of Sciences"
    And I press "Save"
    And I go to the activity feed
    Then I should see "Archibald added the institution CASC" and no other feed items

    When I follow "History"
    Then I should see "Current version"

  Scenario: Comparing reference revisions
    When I go to the references page
    And I follow "New"
    And I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
    And I fill in "reference_title" with "Between Pacific Tides"
    And I fill in "reference_journal_name" with "Ants"
    And I fill in "reference_series_volume_issue" with "2"
    And I fill in "article_pagination" with "1"
    And I fill in "reference_citation_year" with "1992"
    And I press "Save"
    And I follow "History"
    Then I should see "Current version"

  Scenario: Comparing revisions (taxa)
    Given there is a genus "Atta"
    And I go to the edit page for "Atta"
    And I select "(none)" from "taxon_incertae_sedis_in"
    And I save the taxon form

    When I go to the catalog page for "Atta"
    And I follow "History"
    Then I should see "Compare selected revisions"

  Scenario: Comparing revisions (tooltips)
    Given this tooltip exists
      | key      | text      |
      | whatever | Typo oops |

    When I go to the tooltips editing page
    And I follow "whatever"
    And I fill in "tooltip[text]" with "A title"
    And I press "Update Tooltip"

    When I go to the tooltips editing page
    And I follow "whatever"
    And I follow "History"
    Then I should see "Compare selected revisions"
