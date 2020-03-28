Feature: Export references to EndNote
  Scenario: Exporting an `ArticleReference`
    Given there is an article reference

    When I go to the page of the most recent reference
    And I follow "EndNote"
    Then I should see "%0 Journal Article %A Fisher"
