@dormant @javascript
Feature: Author name case-sensitivity
  As Marek
  I want to respect the case of an author's name in the source of a reference
  So that the bibliography is accurate

  Scenario: Using the name that was entered
    Given I am logged in
    And the following references exist
      | author     | title          | year | citation   |
      | Ward, P.S. | Annals of Ants | 2010 | Psyche 1:1 |
    And an author name exists with a name of "Mackay"
    And an author name exists with a name of "MACKAY"
    And an author name exists with a name of "mackay"
    When I go to the references page
    And I follow "edit"
    When I fill in "reference_author_names_string" with "MACKAY"
    And I press the "Save" button
    Then I should see "MACKAY"
    When I follow "edit"
    And I fill in "reference_author_names_string" with "mackay"
    And I press the "Save" button
    Then I should see "mackay"

