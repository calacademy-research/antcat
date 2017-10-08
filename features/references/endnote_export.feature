@javascript
Feature: Export references to EndNote
  Scenario: Exporting an article reference
    Given there is an article reference

    When I go to the page of the most recent reference
    And I hover the export button
    And I follow "EndNote"
    Then I should see "%0 Journal Article %A Fisher"
