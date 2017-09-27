Feature: Edit reference successfully
  As Phil Ward
  I want to change previously entered references
  So that I can fix mistakes

  Background:
    Given I am logged in

  @javascript
  Scenario: Edit a reference
    Given this reference exists
      | authors | citation   | title | year |
      | authors | Psyche 5:3 | title | 2010 |

    When I go to the edit page for the most recent reference
    And I fill in "reference_author_names_string" with "Ward, B.L.;Bolton, B."
    And I fill in "reference_title" with "Ant Title"
    And I fill in "reference_citation_year" with "1910a"
    And I press "Save"
    Then I should see "Ward, B.L.; Bolton, B. 1910a. Ant Title"

  @javascript
  Scenario: Change a reference's type
    Given this reference exists
      | authors    | title | citation   | year |
      | Fisher, B. | Ants  | Psyche 6:4 | 2010 |

    When I go to the edit page for the most recent reference
    And I follow "Book"
    And I fill in "reference_publisher_string" with "New York: Wiley"
    And I fill in "book_pagination" with "22 pp."
    And I press "Save"
    Then I should see "Fisher, B. 2010. Ants. New York: Wiley, 22 pp."

  @javascript
  Scenario: See the correct tab initially (book reference)
    Given this book reference exists
      | authors    | title | citation                | year |
      | Fisher, B. | Ants  | New York: Wiley, 22 pp. | 2010 |

    When I go to the edit page for the most recent reference
    And I fill in "reference_publisher_string" with "New York: Harcourt"
    And I press "Save"
    Then I should see "Fisher, B. 2010. Ants. New York: Harcourt, 22 pp."

  @javascript
  Scenario: See the correct tab initially (unknown reference)
    Given this unknown reference exists
      | authors    | title | citation | year |
      | Fisher, B. | Ants  | New York | 2010 |

    When I go to the edit page for the most recent reference
    And I fill in "reference_citation" with "New Jersey"
    And I press "Save"
    Then I should see "Fisher, B. 2010. Ants. New Jersey."

  @javascript
  Scenario: Specifying the document URL
    Given there is a reference

    When I go to the edit page for the most recent reference
    And I fill in "reference_document_attributes_url" with a URL to a document that exists
    And I press "Save"
    Then I should see a PDF link

  #Scenario: Setting a document's publicness
    #Given there is a reference
    #And that the entry has a URL that's on our site
    #When I go to the references page
    #Then I should see a "PDF" link
    #When I log in
    #And I go to the references page
    #And I follow "edit" in the first reference
    #And I check "reference_document_attributes_public" in the first reference
    #And I press "Save"
    #And I log out
    #And I go to the references page
    #Then I should see a "PDF" link

  @javascript
  Scenario: Edit a nested reference
    Given this reference exists
      | authors    | citation   | year | title |
      | Ward, P.S. | Psyche 5:3 | 2001 | Ants  |
    And the following entry nests it
      | authors    | title            | year | pages_in |
      | Bolton, B. | Ants are my life | 2001 | In:      |

    When I go to the references page
    Then I should see "Bolton, B. 2001. Ants are my life. In: Ward, P.S. 2001. Ants. Psyche 5:3"

    When I go to the edit page for the most recent reference
    And I fill in "reference_pages_in" with "Pp. 32 in:"
    And I press "Save"
    Then I should see "Bolton, B. 2001. Ants are my life. Pp. 32 in: Ward, P.S. 2001. Ants. Psyche 5:3"
