Feature: Latest Additions (seeing what's new)
  As an editor of AntCat
  I want to see recently added references
  So I can keep up with the state of the literature

  Background:
    Given there is a reference
    And I am logged in
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

  Scenario: Changing the default reference button on the latest reference additions page
    Given PENDING
    # TODO this test just tests itself, and it's not even working.
    Given there is no default reference

    When I go to the latest reference additions page
    Then I should not see "Default"

    When I follow "Make default"
    Given the default reference is "Ward 2010"
    And I go to the latest reference additions page
    Then I should see "Default"
    And I should not see "Make default"
