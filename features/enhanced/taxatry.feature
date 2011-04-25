Feature: Using the Taxatry
  As a user of AntCat
  I want to view the taxonomy of ants either as an index or continuously
  So that I can get information easily

  Scenario: Going to landing page
    When I go to the main page
    Then the "Index" tab should be selected

  Scenario: Going from the index to the browser
    When I go to the main page
    And I choose "Browser"
    Then the "Browser" tab should be selected

  Scenario: Going from the index to the browser
    When I go to the main page
      And I choose "Browser"
      And I choose "Index"
    Then the "Index" tab should be selected
