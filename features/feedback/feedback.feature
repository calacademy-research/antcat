@javascript
Feature: Feedback
  As an user or editor of AntCat
  I want to sumit feedback and corrections
  So that we can improve the catalog

  Background:
    Given I go to the catalog

  Scenario: Showing/hiding the feedback form
    Then I should not see the feedback form
    When I click on the Feedback link
    Then I should see the feedback form

    When I close the feedback form
    Then I should not see the feedback form

  Scenario: Remember entered values when toggling show/hide
    When I click on the Feedback link
      And I fill in "feedback_name" with "Archibald"
      And I fill in "feedback_email" with "archie@antcat.org"
      And I fill in "feedback_comment" with "Great site!!!"
      And I fill in "feedback_page" with "catalog/123"
      And I close the feedback form

    When I click on the Feedback link
    Then I should see the feedback form
      And the name field within the feedback form should contain "Archibald"
      And the email field within the feedback form should contain "archie@antcat.org"
      And the comment field within the feedback form should contain "Great site!!!"
      And the page field within the feedback form should contain "catalog/123"

  Scenario: Nothing except a comment is required
    When I click on the Feedback link
    And I press "Send Feedback"
    Then I should see "Whoops, error: comment can't be blank"

    When I fill in "feedback_comment" with "Great site!!!"
    And I press "Send Feedback"
    Then I should see "Message sent"

  Scenario: Showing a thank-you notice
    When I click on the Feedback link
      And I fill in "feedback_comment" with "Great site!!!"
      And I press "Send Feedback"
    Then I should see "Message sent"
    And I should see "Thanks for helping us make AntCat better!"

  @no_travis
  Scenario: Unregistered user submitting feedback
    When I click on the Feedback link
      And I fill in "feedback_comment" with "Great site!!!"
      And I press "Send Feedback"
      And I go to the feedback mailer preview
    Then the email should contain "From: [no name] <[no email];"

  @no_travis
  Scenario: Registered user submitting feedback
    Given I log in as a catalog editor named "Archibald"

    When I click on the Feedback link
      And I fill in "feedback_comment" with "Great site!!!"
      And I press "Send Feedback"
      And I go to the feedback mailer preview
    Then the email should contain "From: Archibald (registered AntCat user)"

  Scenario: Page field defaults to the current URL
    Given there is a genus "Calyptites"

    When I go to the catalog page for "Calyptites"
    And I click on the Feedback link
    Then I should see the feedback form
    And the page field within the feedback form should contain "catalog/"

  Scenario: Resetting the form after submit, but remember name/email
    When I click on the Feedback link
    And I press "Send Feedback"
    Then I should see "Whoops, error: comment can't be blank"

    When I fill in "feedback_comment" with "Great site!!!"
    And I press "Send Feedback"
    Then I should see "Message sent"
    And I should see "Thanks for helping us make AntCat better!"
