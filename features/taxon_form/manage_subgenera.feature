Feature: Manage subgenera
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Setting and removing a subgenus of a species (with feed)
    Given there is a subgenus "Camponotus (Myrmentoma)" in the genus "Camponotus"
    And there is a species "Camponotus cornis" in the genus "Camponotus"

    When I go to the catalog page for "Camponotus cornis"
    Then I should not see "Camponotus (Myrmentoma)" within the breadcrumbs

    When I follow "Set subgenus" within the breadcrumbs
    And I follow "Set"
    Then I should see "Successfully updated subgenus of species"

    When I go to the catalog page for "Camponotus cornis"
    Then I should see "Camponotus (Myrmentoma)" within the breadcrumbs

    When I go to the activity feed
    Then I should see "Archibald set the subgenus of Camponotus cornis to Camponotus (Myrmentoma)" within the activity feed

    When I go to the catalog page for "Camponotus cornis"
    And I follow "Set subgenus" within the breadcrumbs
    And I follow "Remove"
    Then I should see "Successfully removed subgenus from species"

    When I go to the catalog page for "Camponotus cornis"
    Then I should not see "Camponotus (Myrmentoma)" within the breadcrumbs

    When I go to the activity feed
    Then I should see "Archibald removed the subgenus from Camponotus cornis (subgenus was Camponotus (Myrmentoma))" within the activity feed
