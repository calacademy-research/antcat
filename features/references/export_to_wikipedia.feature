@javascript
Feature: Export references to Wikipedia
  As an editor of Wikipedia
  I want generate wiki-formatted citation templates
  So that it's easier to add references to Wikipedia articles

  Scenario: Exporting an article reference
    Given this reference exists
      | authors    | year | citation_year | title     | citation |
      | Ward, P.S. | 2010 | 2010d         | Ant Facts | Ants 1:1 |

    When I go to the references page
    And I follow first reference link
    And I hover the export button
    And I follow "Wikipedia"
    Then I should see "{{cite journal"

  Scenario: Exporting a book reference
    Given this book reference exists
      | authors    | year | title | citation                |
      | Bolton, B. | 2010 | Ants  | New York: Wiley, 23 pp. |

    When I go to the references page
    And I follow first reference link
    And I hover the export button
    And I follow "Wikipedia"
    Then I should see "{{cite book"
