Feature: Using the Taxatry
  As a user of AntCat
  I want to view the taxonomy of ants either as an index or continuously
  So that I can get information easily

  Scenario: Going to landing page
    When I go to the main page
    Then "Browser view" should be available
      And "Index view" should not be available

  Scenario: Going from the index to the browser
    When I go to the main page
    And I follow "Browser view"
    Then "Index view" should be available
      And "Browser view" should not be available

  Scenario: Going from the index to the browser
    When I go to the main page
      And I follow "Browser view"
      And I follow "Index view"
    Then "Browser view" should be available
      And "Index view" should not be available
