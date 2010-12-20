Feature: Error handling
  As Phil Ward
  I want to see what's wrong when there's an error
  So that I can fix mistakes

  Scenario: Cancelling edit after an error
    Given I am logged in
      And the following entry exists in the bibliography
      |authors       |year|title                     |citation                   |
      |Forel, A.     |1874|Les fourmis de la Suisse  |Neue Denkschriften 26:1-452|
    When I go to the main page
      And I follow "edit"
      And I fill in "reference_title" with ""
      And I press the "Save" button
    Then I should see "Title can't be blank"
    When I press the "Cancel" button
    Then I should see "Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452."
    When I follow "edit"
    Then I should not see any error messages
    When I press the "Save" button
    Then I should not see any error messages
      And I should see "Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452."
