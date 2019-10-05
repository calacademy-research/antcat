Feature: Author name case-sensitivity
  As Marek
  I want to respect the case of an author's name in the source of a reference
  So that the bibliography is accurate

  Scenario: Using the name that was entered
    Given I log in as a helper editor
    And there is a reference
    And an author name exists with a name of "Mackay"
    And an author name exists with a name of "MACKAY"
    And an author name exists with a name of "mackay"

    When I go to the edit page for the most recent reference
    And I fill in "reference_author_names_string" with "MACKAY"
    And I press "Save"
    Then I should see "MACKAY"

    When I go to the edit page for the most recent reference
    And I fill in "reference_author_names_string" with "mackay"
    And I press "Save"
    Then I should see "mackay"
