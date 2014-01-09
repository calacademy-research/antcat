Feature: Replace missing references

  Scenario: Seeing a missing reference in action
    #Given there is a missing reference with "Bolton, 1970" as the citation
    And these references exist
      | authors | citation   | cite_code | created_at | date     | possess | title | updated_at | year |
      | Fisher  | Psyche 3:3 | CiteCode  | today      | 20100712 | Possess | title | today      | 2010 |
    #Then I should see "Bolton, 1970" in the missing reference list
    #When I click the first missing reference
    #And I pick a replacement from the references
    #And I will confirm
    #And I click "Replace with"
    #Then I should not see the missing reference in the list
