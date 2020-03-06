@javascript
Feature: Feedback
  As an user or editor of AntCat
  I want to submit feedback and corrections
  So that we can improve the catalog

  Background:
    Given I go to the catalog

  Scenario: Showing/hiding the feedback form
    Then I should not see the feedback form

    When I click the Feedback link
    Then I should see the feedback form

    When I close the feedback form
    Then I should not see the feedback form

  # TODO: The "waits" are because this started to happen after switching driver to apparition:
  # ```
  # And the email field within the feedback form should contain "flint@antcat.org" # features/step_definitions/feedback_steps.rb:17
  #   expected "flint@an" to include "flint@antcat.org" (RSpec::Expectations::ExpectationNotMetError)
  # ```
  # See https://github.com/teamcapybara/capybara/issues/1890
  Scenario: Remember entered values when toggling show/hide
    When I click the Feedback link
    And I fill in "feedback_name" with "Captain Flint"
    And WAIT
    And I fill in "feedback_email" with "flint@antcat.org"
    And WAIT
    And I fill in "feedback_comment" with "Great site!!!"
    And I fill in "feedback_page" with "catalog/123"
    And WAIT
    And I close the feedback form

    When I click the Feedback link
    Then I should see the feedback form
    And the name field within the feedback form should contain "Captain Flint"
    And the email field within the feedback form should contain "flint@antcat.org"
    And the comment field within the feedback form should contain "Great site!!!"
    And the page field within the feedback form should contain "catalog/123"

  Scenario: Nothing except a comment is required
    When I click the Feedback link
    And I click css "#submit-feedback-js"
    Then I should see "Whoops, error: Comment can't be blank"

    When I fill in "feedback_comment" with "Great site!!!"
    And I click css "#submit-feedback-js"
    Then I should see "Message sent"

  Scenario: Unregistered user submitting feedback (with feed)
    When I click the Feedback link
    And I fill in "feedback_comment" with "Great site!!!"
    And I click css "#submit-feedback-js"
    Then I should see "Message sent"
    And I should see "Thanks for helping us make AntCat better!"

    When I log in as a catalog editor
    And I go to the feedback page
    Then I should see "[no name] <[no email];"

    When I go to the activity feed
    Then I should see "An unregistered user added the feedback item #" within the feed

  Scenario: Registered user submitting feedback (with feed)
    Given I log in as a catalog editor named "Archibald"

    When I click the Feedback link
    And I fill in "feedback_comment" with "Great site!!!"
    And I click css "#submit-feedback-js"
    Then I should see "Message sent"

    When I go to the feedback page
    Then I should see "Archibald submitted"

    When I go to the activity feed
    Then I should see "Archibald added the feedback item #" within the feed

  Scenario: Page field defaults to the current URL
    Given there is a genus "Calyptites"

    When I go to the catalog page for "Calyptites"
    And I click the Feedback link
    Then the page field within the feedback form should contain "catalog/"

  Scenario: Unregistered users may be throttled
    Given I have already posted 5 feedbacks in the last 5 minutes

    When I click the Feedback link
    And I click css "#submit-feedback-js"
    Then I should see "You have already posted a couple of feedbacks in the last few minutes"
    And I should not see "Message sent"

  Scenario: Combating spambots with honeypots
    When I click the Feedback link
    And I fill in "feedback_comment" with "buy rolex plz"
    And I pretend to be a bot by filling in the invisible work email field
    And I click css "#submit-feedback-js"
    Then I should see "You're not a bot are you?"
    And I should not see "Message sent"
