# TODO: Something is broken in the `@responsive` tag:
# @javascript @responsive
Feature: Responsive navigation
  As a user of AntCat
  I want be able to browse the site from any device

  Scenario: Desktop/mobile layout
    # Test broke after apdating Rails.
    Given PENDING
    When I go to the catalog
    Then I should see the desktop layout

    When I resize the browser window to mobile
    Then I should see the mobile layout
