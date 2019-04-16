Feature: Latest Additions
  As an editor of AntCat
  I want to see recently added references
  So I can keep up with the state of the literature

  Background:
    Given there is a reference
    And I am logged in as a catalog editor
    And I go to the latest reference additions page

  Scenario: Start reviewing
    Then I should not see "Being reviewed"

    When I follow "Start reviewing"
    Then I should see "Being reviewed"

  Scenario: Stop reviewing
    Then I should not see "Reviewed"

    When I follow "Start reviewing"
    And I follow "Finish reviewing"
    Then I should see "Reviewed"

  Scenario: Restart reviewing
    Then I should not see "Being reviewed"

    When I follow "Start reviewing"
    And I follow "Finish reviewing"
    And I follow "Restart reviewing"
    Then I should see "Being reviewed"
