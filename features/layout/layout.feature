Feature: Layout
  Background:
    Given I am logged in

  Scenario: Showing unescaped HTML characters in the title
    When I go to the Editor's Panel
    Then the page title be "Editor's Panel - AntCat (test)"
