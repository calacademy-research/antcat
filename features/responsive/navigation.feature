@javascript @responsive
Feature: Responsive navigation
  As a user of AntCat
  I want be able to browse the site from any device

  Background:
    Given the Formicidae family exists

  Scenario: Desktop/mobile layout
    When I go to the catalog
    Then I should see the desktop layout

    When I resize the browser window to mobile
    Then I should see the mobile layout
