Feature: Browse Feedback
  As an editor of AntCat
  I read user feedback
  So that we can improve the catalog

  Scenario: Non-editor trying to browse submitted feedback
    When I go to the feedback index
    Then I should be on the login page

  Scenario: Browsing submitted feedback
    Given a visitor has submitted a feedback with the comment "Mad catalog!"
    And I am logged in

    When I go to the feedback index
    Then I should see "[no name] <[no email]; IP 127.0.0.1> submitted"
    And I should see "Mad catalog!"

  Scenario: Displaying a single feedback item
    Given a visitor has submitted a feedback with the comment "Mad catalog!"
    And I am logged in

    When I go to the most recent feedback item
    Then I should see "From: [no name] <[no email]; IP 127.0.0.1>"
    And I should see "Mad catalog!"
