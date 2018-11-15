Feature: Browse Feedback
  As an editor of AntCat
  I want to read user feedback
  So that we can improve the catalog

  Background:
    Given a visitor has submitted a feedback with the comment "Mad catalog!"

  Scenario: Non-editor trying to browse submitted feedback
    When I go to the feedback index
    Then I should be on the login page

  Scenario: Browsing submitted feedback index
    Given I am logged in as a helper editor

    When I go to the feedback index
    Then I should see "[no name] <[no email]; IP 127.0.0.1> submitted"
    And I should see "Mad catalog!"

  Scenario: Displaying a single feedback item
    Given I am logged in as a helper editor

    When I go to the most recent feedback item
    Then I should see "[no name] <[no email]; IP 127.0.0.1> submitted"
    And I should see "Mad catalog!"

  @javascript
  Scenario: Show formatted for email (to use when replying)
    Given I am logged in as a helper editor

    When I go to the most recent feedback item
    Then I should not see "Formatted for email"

    When I follow "Hide/show formatted for email"
    Then I should see "Formatted for email"
