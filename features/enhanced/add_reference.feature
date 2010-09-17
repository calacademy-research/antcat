Feature: Add reference
  As Phil Ward
  I want to add new references
  So that the bibliography continues to be up-to-date

  Scenario: Not logged in
    Given I am not logged in
    When I go to the main page
      Then I should not see "Add reference"

  Scenario: Add a reference when there are no others
    Given I am logged in
    When I go to the main page
      And I follow "Add reference"
      Then I should see a new edit form
    When I fill in "reference_authors_string" with "Ward, B.L.;Bolton, B."
      And I fill in "reference_title" with "A reference title"
      And I fill in "reference_citation_year" with "1981"
      And I press "OK"
    Then I should be on the main page
      And I should not see a new edit form
      And I should see "Ward, B.L.; Bolton, B. 1981. A reference title"
      And "Add reference" should not be visible

  Scenario: Add but cancel a reference when there are no others
    Given I am logged in
    When I go to the main page
      And I follow "Add reference"
    When I fill in "reference_title" with "Mark Wilden"
      And I press "Cancel"
      And I should not see "Mark Wilden"

  Scenario: Add a reference when there are others
    Given I am logged in
      And the following entries exist in the bibliography
      |authors   |title         |year|citation|
      |Ward, P.S.|Annals of Ants|year|Psyche 1:1|
    When I go to the main page
      Then "Add reference" should not be visible
    When I follow "add"
      Then I should see a new edit form
    When in the new edit form I fill in "reference_authors_string" with "Ward, B.L.;Bolton, B."
      And in the new edit form I fill in "reference_title" with "Between Pacific Tides"
      And in the new edit form I fill in "reference_citation_year" with "1992"
      And in the new edit form I press "OK"
    Then I should be on the main page
      And I should not see a new edit form
      And I should see "Ward, B.L.; Bolton, B. 1992. Between Pacific Tides."

  Scenario: Adding a reference but then cancelling
    Given I am logged in
      And the following entries exist in the bibliography
      |authors   |title         |citation|year|
      |Ward, P.S.|Annals of Ants|Psyche 2:2|year|
    When I go to the main page
    When I follow "add"
    When in the new edit form I fill in "reference_title" with "Mark Wilden"
      And in the new edit form I press "Cancel"
    Then there should be just the existing reference

  Scenario: Hide Delete button while adding
    Given I am logged in
    When I go to the main page
      And I follow "Add reference"
      Then I should see a new edit form
        And I should not see a "Delete" button
