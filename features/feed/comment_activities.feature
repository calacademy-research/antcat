@feed
Feature: Feed (comments)
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Added comment
    Given a visitor has submitted a feedback with the comment "Fix spelling"
    And I log in as a catalog editor named "Archibald"

    When I go to the feedback index
      And follow the link of the first feedback
      And I write a new comment "Fixed."
      And I press "Post Comment"
    And I go to the activity feed
    Then I should see "Archibald commented on the feedback #"
