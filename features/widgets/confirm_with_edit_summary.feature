Feature: Prompts with edit summaries
  @javascript
  Scenario: Entering an edit summary in the prompt
    Given a visitor has submitted a feedback
    And I log in as a superadmin named "Archibald"

    When I go to the most recent feedback item
    And I will enter "spam feedback" in the prompt and confirm on the next step
    And I follow "Delete"
    And I go to the activity feed
    Then I should see "Archibald deleted the feedback item #"
    And I should see the edit summary "spam feedback"
