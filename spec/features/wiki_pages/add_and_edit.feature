Feature: Add and edit wiki pages
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Adding a wiki page (with edit summary)
    When I go to the wiki pages index
    Then I should see "There are currently no wiki pages"

    When I follow "New"
    And I fill in "wiki_page_title" with "Bibliography guidelines"
    And I fill in "wiki_page_content" with "In the title, use capitals only"
    And I fill in "edit_summary" with "added help page"
    And I press "Save"
    Then I should see "Successfully created wiki page"

    When I go to the wiki pages index
    Then I should see "Bibliography guidelines"

    When I follow the first "Bibliography guidelines"
    Then I should see "In the title, use capitals only"

    When I go to the activity feed
    Then I should see "Archibald added the wiki page Bibliography guidelines" within the activity feed
    And I should see the edit summary "added help page"

  Scenario: Editing a wiki page (with edit summary)
    Given there is a wiki page "Catalog guidelines"

    When I go to the wiki pages index
    And I follow the first "Catalog guidelines"
    And I follow "Edit"
    And I fill in "wiki_page_title" with "Name guidelines"
    And I fill in "wiki_page_content" with "Genus names must start with a capital letter"
    And I fill in "edit_summary" with "updated info"
    And I press "Save"
    Then I should see "Successfully updated wiki page"

    When I go to the wiki pages index
    And I should see "Name guidelines"

    When I follow the first "Name guidelines"
    Then I should see "Genus names must start with a capital letter"

    When I go to the activity feed
    Then I should see "Archibald edited the wiki page Name guidelines" within the activity feed
    And I should see the edit summary "updated info"
