Feature: Merging authors
  As an editor of AntCat
  I want to merge together author names
  So that they are correct

  Background:
    Given the following names exist for an author
      | Bolton, B. |
      | Bolton,B.  |
    And these references exist
      | author     | title          |
      | Bolton, B. | Annals of Ants |
      | Bolton,B.  | More ants      |
    And the following names exist for another author
      | Fisher, B. |
    And I go to the merge authors page

  Scenario: Searching for an author
    When I search for "Bolton, B." in the author panel
    Then I should see "Bolton, B." in the author panel
    And I should see "Bolton,B." in the author panel
    And I should see "Annals of Ants" in the author panel
    And I should see "More ants" in the author panel

  Scenario: Searching for an author that isn't found
    When I search for "asdf" in the author panel
    Then I should see "No results found" in the author panel

  Scenario: Opening more than one search panel
    When I search for "Bolton, B." in the author panel
    And I search for "Fisher, B." in another author panel
    Then I should see "Bolton, B." in the first author panel
    And I should see "Fisher, B." in the second author panel

  Scenario: Searching for an author that's already open in another panel
    When I search for "Bolton, B." in the author panel
    And I search for "Bolton, B." in another author panel
    Then I should see "Bolton, B." in the first author panel
    And I should see "This author is open in another panel" in the second author panel

  Scenario: Closing a panel
    Given I search for "Bolton, B." in the author panel

    When I search for "Fisher, B." in another author panel
    And I close the first author panel
    Then I should see "Fisher, B." in the first author panel
    And I should not see "Bolton, B."

  Scenario: Merging
    Given I am logged in

    When I go to the merge authors page
    And I search for "Bolton, B." in the author panel
    And I search for "Fisher, B." in another author panel
    And I merge the authors
    Then I should see "Bolton, B." in the first author panel
    And I should see "Fisher, B." in the first author panel

  Scenario: Not logged in - can't merge
    When I search for "Bolton, B." in the author panel
    And I search for "Fisher, B." in another author panel
    Then I should not be able to merge the authors
