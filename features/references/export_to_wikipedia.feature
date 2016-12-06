@javascript
Feature: Export references to Wikipedia
  As an editor of Wikipedia
  I want generate wiki-formatted citation templates
  So that it's easier to add references to Wikipedia articles

  Scenario: Exporting an article reference
    Given there is an article reference

    When I go to the page of the most recent reference
    And I hover the export button
    And I follow "Wikipedia"
    Then I should see "{{cite journal"

  Scenario: Exporting a book reference
    Given there is a book reference

    When I go to the page of the most recent reference
    And I hover the export button
    And I follow "Wikipedia"
    Then I should see "{{cite book"
