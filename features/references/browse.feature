Feature: View bibliography
  As a researcher
  I want to see what the literature is for ant taxonomy
  So that I can obtain it and read it

  Scenario: View one entry
    Given this reference exists
      | authors    | year | title     | citation | public_notes | editor_notes   |
      | Ward, P.S. | 2010 | Ant Facts | Ants 1:1 | Public notes | Editor's notes |

    When I go to the references page
    Then I should see "Ward, P.S. 2010. Ant Facts. Ants 1:1"
    And I should see "Public notes"
    And I should not see "Editor's notes"

  Scenario: View one entry with italics
    Given this reference exists
      | title                                             | authors | citation | year |
      | Territory \|defense\| by the ant *Azteca trigona* | authors | Ants 2:2 | year |

    When I go to the references page
    Then I should see "Azteca trigona" italicized
    And I should see "defense" italicized

  Scenario: Viewing an entry with a URL to a document on our site, but the user isn't logged in
    Given there is a reference
    And that the entry has a URL that's on our site

    When I go to the references page
    Then I should see a "PDF" link

  Scenario: Viewing an entry with a URL to a document on our site, the user isn't logged in, but it's public
    Given there is a reference
    And that the entry has a URL that's on our site that is public

    When I go to the references page
    Then I should see a "PDF" link

  Scenario: Viewing an entry with a URL to a document that's not on our site, and the user isn't logged in
    Given there is a reference
    And that the entry has a URL that's not on our site

    When I go to the references page
    Then I should see a "PDF" link

  Scenario: Viewing an entry with a URL to a document on our site, but the user is logged in
    Given there is a reference
    And that the entry has a URL that's on our site
    And I am logged in

    When I go to the references page
    Then I should see a "PDF" link

  Scenario: Viewing an entry with a URL to a document that's not on our site, and the user is logged in
    Given there is a reference
    And that the entry has a URL that's not on our site
    And I am logged in

    When I go to the references page
    Then I should see a "PDF" link

  Scenario: Viewing a nested reference
    Given there is a book reference
    And the following entry nests it
      | authors    | title          | year | pages_in |
      | Ward, P.S. | Dolichoderinae | 2010 | In:      |

    When I go to the references page
    Then I should see "Ward, P.S. 2010. Dolichoderinae. In: "

  Scenario: Viewing a missing reference
    Given this reference exists
      | authors    | year | title     | citation |
      | Ward, P.S. | 2010 | Ant Facts | Ants 1:1 |
    And there is a missing reference

    When I go to the references page
    Then I should not see the missing reference
    And I should see "Ward, P.S. 2010. Ant Facts. Ants 1:1 "

  Scenario: Not logged in
    Given this reference exists
      | authors | citation   | title | year | public_notes | editor_notes | taxonomic_notes |
      | authors | Psyche 3:3 | title | 2010 | Public       | Editor       | Taxonomy        |
    And I am not logged in

    When I go to the references page
    Then I should see "Public"
    And I should not see "Editor"
    And I should not see "Taxonomy"

  Scenario: Logged in
    Given this reference exists
      | authors | citation   | title | year | public_notes | editor_notes | taxonomic_notes |
      | authors | Psyche 3:3 | title | 2010 | Public       | Editor       | Taxonomy        |
    And I am logged in

    When I go to the references page
    Then I should see "Public"
    And I should see "Editor"
    And I should see "Taxonomy"
