Feature: Edit reference
  As Phil Ward
  I want to change previously entered references
  So that I can fix mistakes

  Scenario: Edit a reference
    Given the following entries exist in the bibliography
      |authors|citation|cite_code|created_at|date    |possess|title|updated_at|year|
      |Authors|Citation|CiteCode |today     |20100712|Possess|Title|today     |2010|
    When I go to the main page
      And I follow "Authors 2010. Title Citation"
    Then I should be on the page for that reference
    When I follow "Edit"
    Then I should be on the edit page for that reference
    When I fill in "Year" with "1758"
      And I press "Update"
    Then I should be on the page for that reference
      And I should see "1758"
      And I should see "Reference has been updated"

  Scenario: Cancel editing a reference
    Given the following entries exist in the bibliography
      |authors|citation|cite_code|created_at|date    |possess|title|updated_at|year|
      |Authors|Citation|CiteCode |today     |20100712|Possess|Title|today     |2010|
    When I go to the main page
      And I follow "Authors 2010. Title Citation"
      And I follow "Edit"
      And I fill in "Year" with "1758"
      And I press "Cancel"
    Then I should be on the page for that reference
      And I should see "2010"
      And I should not see "1758"
