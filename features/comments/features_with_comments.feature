Feature: Features with comments
  As an AntCat editor
  I want to comment on open tasks, user feedbacks and site notices
  So that editors can track issues

  Background:
    Given I log in as a catalog editor named "Batiatus"

  Scenario: Commenting on open tasks
    Given there is an open task "Fix spelling"

    When I go to the open tasks page
    And I follow "Fix spelling"
    Then I should see a comments section

  Scenario: Commenting on user feedbacks
    Given a visitor has submitted a feedback with the comment "Fix spelling"

    When I go to the most recent feedback item
    Then I should see a comments section

  Scenario: Commenting on site notices
    Given there is a site notice I haven't read yet

    When I go to the site notices page
    And I follow "A Site Notice" within "table"
    Then I should see a comments section
