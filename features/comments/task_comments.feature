Feature: Comment on tasks
  As an AntCat editor
  I want to comment on open tasks

  Background:
    Given I log in as a catalog editor named "Batiatus"
    And there is an open task "Fix spelling"
    And I go to the open tasks page
    And I follow "Fix spelling"

  Scenario: Commenting on an open task
    When I write a new comment "hmm.. nope is spelled correctly"
    And I press "Post Comment"
    Then I should see "Comment was successfully added"
    And I should see "nope is spelled correctly"

  @javascript
  Scenario: Replying to a comment
    Given I write a new comment "hmm.. nope is spelled correctly"
    And I press "Post Comment"

    When I follow "reply"
    And I write a reply with the text "oooh, close task then"
    And I press "Post Reply"
    Then I should see "Comment was successfully added"
    And I should see "nope is spelled correctly"
    And I should see "oooh, close task then"
