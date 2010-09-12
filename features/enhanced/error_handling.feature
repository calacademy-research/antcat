Feature: Error handling
  As Phil Ward
  I want to see what's wrong when there's an error
  So that I can fix mistakes

  Scenario: Error when editing a reference
    Given I am logged in
      And the following entry exists in the bibliography
      |authors       |year |title                     |citation                   |
      |Forel, A.     |1874 |Les fourmis de la Suisse  |Neue Denkschriften 26:1-452|
    When I go to the main page
      And I click the reference
      And I fill in "reference_authors" with ""
      And I press "OK"
    Then I should see the edit form
      And I should see "Authors can't be blank"
      And "reference_authors" should be marked as an error
    When I fill in "reference_authors" with "Wheeler, D.M."
      And I press "OK"
    Then I should not see the edit form
      And I should not see any error messages
      And I should see "Wheeler, D.M. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452."

  Scenario: Cancelling edit after an error
    Given I am logged in
      And the following entry exists in the bibliography
      |authors       |year |title                     |citation                   |
      |Forel, A.     |1874 |Les fourmis de la Suisse  |Neue Denkschriften 26:1-452|
    When I go to the main page
      And I click the reference
      And I fill in "reference_authors" with ""
      And I press "OK"
    Then I should see "Authors can't be blank"
    When I press "Cancel"
    Then I should see "Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452."
    When I click the reference
    Then I should not see any error messages
    When I press "OK"
    Then I should not see any error messages
      And I should see "Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452."
