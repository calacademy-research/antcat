Feature: Going to the landing page
  As a researcher
  I want to go to the index when I go to antcat.org
  Because that's the coolest-looking page

  Scenario: Going to the landing page
    When I go to the main page
    Then I should see "Online Catalog"
