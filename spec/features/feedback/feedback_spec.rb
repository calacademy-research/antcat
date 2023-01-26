Feature: Feedback
  As an user or editor of AntCat
  I want to submit feedback and corrections
  So that we can improve the catalog

  Background:
    Given I go to the catalog

  Scenario: Nothing except a comment is required
    When I follow "Suggest edit"
    And I press "Send Feedback"
    Then I should see "Comment can't be blank"

    When I fill in "feedback_comment" with "Great site!!!"
    And I press "Send Feedback"
    Then I should see "Message sent"

  Scenario: Unregistered user submitting feedback (with feed)
    When I follow "Suggest edit"
    And I fill in "feedback_comment" with "Great site!!!"
    And I press "Send Feedback"

    Then I should see "Message sent"
    And I should see "Thanks for helping us make AntCat better!"

    When I log in as a catalog editor
    And I go to the feedback page
    Then I should see "[no name] <[no email];"

    When I go to the activity feed
    Then I should see "An unregistered user added the feedback item #" within the activity feed

  Scenario: Registered user submitting feedback (with feed)
    Given I log in as a catalog editor named "Archibald"

    When I follow "Suggest edit"
    And I fill in "feedback_comment" with "Great site!!!"
    And I press "Send Feedback"
    Then I should see "Message sent"

    When I go to the feedback page
    Then I should see "Archibald submitted"

    When I go to the activity feed
    Then I should see "Archibald added the feedback item #" within the activity feed

  Scenario: Page field defaults to the current URL
    Given there is a genus "Calyptites"

    When I go to the catalog page for "Calyptites"
    And I follow "Suggest edit"
    Then the "feedback_page" field should contain "catalog/"
