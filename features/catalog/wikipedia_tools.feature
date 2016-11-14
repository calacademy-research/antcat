Feature: Wikipedia tools
  As an editor of Wikipedia
  I want generate a wiki-formatted list of a taxon's children
  And generate Wikipedia citation templates
  So that I can improve Wikipedia's ant-related articles

  Background:
    Given there is genus Atta with two species I want to format for Wikipedia
    When I append "/wikipedia" to the URL of that genus' catalog page

  Scenario: Generating a species list
    Then I should see "==Species=="
    And I should see "''[[Atta cephalotes]]'' <small>"
    And I should see "†''Atta mexicana'' <small>"

  Scenario: Generating a citation template
    Then I should see "==Species=="
    And I should see "<ref name="
    And I should see ">{{AntCat|"
    And I should see "|''Atta''|"
