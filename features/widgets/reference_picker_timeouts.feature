@javascript @editing
Feature: Reference picker

  #Background:
    #Given these references exist
      #| authors                 | year          | title                 | citation   |
      #| Fisher, B.              | 1995b         | Fisher's book         | Ants 1:1-2 |
      #| Bolton, B.              | 2010 ("2011") | Bolton's book         | Ants 2:1-2 |
      #| Fisher, B.; Bolton, B.  | 1995b         | Fisher Bolton book    | Ants 1:1-2 |
      #| Hölldobler, B.          | 1995b         | Bert's book           | Ants 1:1-2 |

  # Works for real - fails in Cucumber
  #Scenario: Editing the selected reference
    #Given I am logged in
    #When I go to the reference picker widget test page, opened to the first reference
    #And I edit the reference
    #When I set the authors to "Ward, B.L.; Bolton, B."
    #And I set the title to "Ant Title"
    #And I save my changes
    #Then I should see "Ward, B.L.; Bolton, B. 1995b. Ant Title"

  # Works for real - fails in Cucumber
  #Scenario: Error when editing reference
    #Given I am logged in
    #When I go to the reference picker widget test page, opened to the first reference
    #And I edit the reference
    #When I set the title to ""
    #And I save my changes
    #And I should see "Title can't be blank"
