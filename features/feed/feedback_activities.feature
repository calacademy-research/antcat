@feed
Feature: Feed (feedback)
  Scenario: Added feedback (non-registered user)
    Given a visitor has submitted a feedback with the comment "Fix spelling"
    And I log in as a catalog editor named "Archibald"

    When I go to the activity feed
    Then I should see "[system] an unregistered user added the feedback item #"

  Scenario: Added feedback (registered user)
    Given I log in as a catalog editor named "Archibald"
    And a visitor has submitted a feedback with the comment "Fix spelling"

    When I go to the activity feed
    Then I should see "Archibald added the feedback item #"

  Scenario: Closed a feedback item
    Given a visitor has submitted a feedback with the comment "Fix spelling"
    And I log in as a catalog editor named "Archibald"

    When I go to the feedback index
      And follow the link of the first feedback
      And I follow "Close"
      And I go to the activity feed
    Then I should see "Archibald closed the feedback item #"

  Scenario: Re-opened a closed feedback item
    Given there is a closed feedback item with the comment "Fix spelling"
    And I log in as a catalog editor named "Archibald"

    When I go to the feedback index
      And follow the link of the first feedback
      And I follow "Re-open"
      And I go to the activity feed
    Then I should see "Archibald re-opened the feedback item #"

  Scenario: Deleted feedback
    # TODO; currently only possible from the ActiveAdmin
