@javascript
Feature: Using the default reference

  Background: 
    Given I am logged in
    And there is a genus "Atta"
    And these references exist
      | author     | title          | year | citation   |
      | Ward, P.S. | Annals of Ants | 2010 | Psyche 1:1 |
    And I go to the references page

  Scenario: Default reference used for new taxon
  When I follow "add" in the first reference
  And in the new edit form I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
  And in the new edit form I fill in "reference_title" with "Between Pacific Tides"
  And in the new edit form I fill in "reference_journal_name" with "Ants"
  And in the new edit form I fill in "reference_series_volume_issue" with "2"
  And in the new edit form I fill in "article_pagination" with "1"
  And in the new edit form I fill in "reference_citation_year" with "1992"
  And in the new edit form I press the "Save" button
  And I wait for a bit
  When the default reference is "Ward 2010"
  And I go to the catalog page for "Atta"
  And I press "Edit"
  And I press "Add species"
  Then the authorship field should contain "Ward, P.S. 2010. Annals of Ants. Psyche 1:1."

  Scenario: Using the default reference in the reference popup
  Given the default reference is "Ward 2010"
  When I go to the reference popup widget test page
  And I press "Ward, 2010"
  And I wait for a bit
  Then the current reference should be "Ward, P.S. 2010. Annals of Ants. Psyche 1:1."

  Scenario: Don't show the button if there's no default
  Given there is no default reference
  When I go to the reference popup widget test page
  Then I should not see the default reference button

  Scenario: Seeing the default reference button on the taxt editor
  Given the default reference is "Ward 2010"
  When I go to the taxt editor test page
  And I press "Ward, 2010"
  Then the taxt editor should contain the editable taxt for "Ward 2010 "

  Scenario: Saving a reference makes it the default
  # I can't write a scenario that uses session

  Scenario: Adding a reference makes it the default
  # I can't write a scenario that uses session

  Scenario: Selecting a reference makes it the default
  # I can't write a scenario that uses session
