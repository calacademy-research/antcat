Feature: Editing a taxon with authorization constraints
  Scenario: Superadmins can login
    Given I log in as a superadmin

    When I go to the main page
    Then I should see "Logout"

  Scenario: Superadmins should have access to Active Admin pages
    Given I log in as a superadmin

    When I go to the main page
    And I follow the first "Editor's Panel"
    Then I should see "Admin dashboard"

  Scenario: Regular users should not have access to Active Admin pages
    Given I am logged in

    When I go to the main page
    And I follow the first "Editor's Panel"
    Then I should not see "Admin dashboard"

  Scenario: Admins to be able to go to the Active Admin pages
    Given I log in as a superadmin

    When I go to the main page
    And I follow the first "Editor's Panel"
    And I follow "Admin dashboard"
    Then I should see "Dashboard"

  Scenario: When admins logout, it should redirect to AntCat root
    Given I log in as a superadmin

    When I go to the main page
    And I follow the first "Editor's Panel"
    And I follow "Admin dashboard"
    Then I should see "Dashboard"

    When I follow the first "Logout"
    Then I should be on the main page

  Scenario: Non-admins should be bounced from admin pages to AntCat root
    Given I am logged in

    When I go to the useradmin page
    Then I should be on the main page

  Scenario: Admins can see the user admin page
    Given I log in as a superadmin

    When I go to the useradmin page
    Then I should be on the useradmin page
