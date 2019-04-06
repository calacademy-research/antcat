# TODO: Something is broken in the `@responsive` tag:
# @javascript @responsive
@skip
Feature: Responsive navigation
  As a user of AntCat
  I want be able to browse the site from any device

  Scenario: Desktop/mobile layout
    When I go to the catalog
    Then I should see the desktop layout

    When I resize the browser window to mobile
    Then I should see the mobile layout
