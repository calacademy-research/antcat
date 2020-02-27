Feature: Copy reference
  As Phil Ward
  I want to add new references using existing reference data
  So that I can reduce copy and pasting beteen references
  And so that the bibliography continues to be up-to-date

  Background:
    Given I log in as a helper editor

  Scenario: Copy an article reference
    Given this reference exist
      | author     | title          | citation | citation_year |
      | Ward, P.S. | Annals of Ants | Ants 1:2 | 1910          |
    And I go to the page of the most recent reference

    When I follow "Copy"
    Then the "Article" tab should be selected
    And the "reference_author_names_string" field should contain "Ward, P.S."
    And the "reference_citation_year" field should contain "1910"
    And the "article_pagination" field should contain "2"
    And the "reference_journal_name" field should contain "Ants"
    And the "reference_series_volume_issue" field should contain "1"
