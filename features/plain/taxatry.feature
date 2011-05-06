Feature: Using the Taxatry
  As a user of AntCat
  I want to view the taxonomy of ants either as an index or continuously
  So that I can get information easily

  Scenario: Going to landing page
    When I go to the main page
    Then the "Browser" tab should be selected
    When I choose "Index"
    Then the "Index" tab should be selected
    When I choose "Browser"
    Then the "Browser" tab should be selected
