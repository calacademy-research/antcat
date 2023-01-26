Feature: Browse recent comments
  Background:
    Given I log in as a catalog editor named "Batiatus"

  Scenario: Parse AntCat markdown of truncated comments
    Given there is an open issue "Test markdown" created by "Batiatus"

    When I go to the issue page for "Test markdown"
    And I write a new comment <at Batiatus's id> "your name should be linked."
    And I press "Post Comment"
    And I wait for the "success" message

    When I go to the comments page
    Then I should see "Batiatus commented on the issue Test markdown:"
    And I should see "@Batiatus your name should be linked."
