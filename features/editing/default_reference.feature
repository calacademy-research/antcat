# Randomly fails.

@javascript
Feature: Using the default reference

  Background:
    Given I am logged in
    And these references exist
      | author     | title          | year | citation   |
      | Ward, P.S. | Annals of Ants | 2010 | Psyche 1:1 |
    And I go to the references page

  Scenario: Default reference used for new taxon
    Given the Formicidae family exists
    Given there is a genus "Atta"
    When I follow "New"
    And I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
    And I fill in "reference_title" with "Between Pacific Tides"
    And I fill in "reference_journal_name" with "Ants"
    And I fill in "reference_series_volume_issue" with "2"
    And I fill in "article_pagination" with "1"
    And I fill in "reference_citation_year" with "1992"
    And I press the "Save" button
    And I wait for a bit
    When the default reference is "Ward 2010"
    And I go to the catalog page for "Atta"
    And I press "Edit"
    And I follow "Add species"
    Then the authorship field should contain "Ward, P.S. 2010. Annals of Ants. Psyche 1:1."

  Scenario: Using the default reference in the reference popup
    Given the default reference is "Ward 2010"
    When I go to the reference popup widget test page
    And I wait for a bit
    And I wait for a bit
    And I press "Ward, 2010"
    Then the current reference should be "Ward, P.S. 2010. Annals of Ants. Psyche 1:1."

  Scenario: Don't show the button if there's no default
    Given there is no default reference
    When I go to the reference popup widget test page
    And I wait for a bit
    Then I should not see the default reference button

  Scenario: Seeing the default reference button on the taxt editor
    Given the default reference is "Ward 2010"
    When I go to the taxt editor test page
    And I hack the taxt editor in test env
    And I press "Ward, 2010"
    Then the taxt editor should contain the editable taxt for "Ward 2010 "

  #Scenario: Saving a reference makes it the default
  #  # TODO? I can't write a scenario that uses session

  #Scenario: Adding a reference makes it the default
  #  # TODO? I can't write a scenario that uses session

  #Scenario: Selecting a reference makes it the default
  #  # TODO? I can't write a scenario that uses session

  Scenario: Cancelling after choosing the default reference
    Given the default reference is "Ward 2010"
    When I go to the reference field test page
    And I click the reference field
    And I press "Ward, 2010"
    And I wait for a bit
    And I press "Cancel"
    Then the authorship field should contain "(none)"
