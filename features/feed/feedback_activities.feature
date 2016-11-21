@feed
Feature: Feed (feedback)
  Scenario: Added feedback (non-registered user)
    Given a visitor has submitted a feedback
    And I log in as a catalog editor named "Archibald"

    When I go to the activity feed
    Then I should see "[system] an unregistered user added the feedback item #"

  Scenario: Added feedback (registered user)
    Given I log in as a catalog editor named "Archibald"
    And a visitor has submitted a feedback

    When I go to the activity feed
    Then I should see "Archibald added the feedback item #"

  Scenario: Closed a feedback item
    Given a visitor has submitted a feedback
    And I log in as a catalog editor named "Archibald"

    When I go to the most recent feedback item
      And I follow "Close"
    And I go to the activity feed
    Then I should see "Archibald closed the feedback item #"

  Scenario: Re-opened a closed feedback item
    Given there is a closed feedback item
    And I log in as a catalog editor named "Archibald"

    When I go to the most recent feedback item
      And I follow "Re-open"
    And I go to the activity feed
    Then I should see "Archibald re-opened the feedback item #"

  Scenario: Deleted feedback
    Given there is a feedback item
    And I log in as a superadmin named "Archibald"

    When I go to the most recent feedback item
      And I follow "Delete"
    And I go to the activity feed
    Then I should see "Archibald deleted the feedback item #"
