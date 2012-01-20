@dormant
Feature: COinS formatting
  As a researcher
  I want to use Zotero to extract citations from AntCat
  So that I don't have to hand-copy them myself
  And so I can use the citations in my own documents

  Scenario: Including COinS on index page
      And the following references exist
      |authors|title|year|citation      |
      |AUTHORS|TITLE|1999|Ecology 12:333|
    When I go to the references page
    Then there should be the HTML "<span class="Z3988" title="ctx_ver=Z39.88-2004"
      And there should be the HTML "rft.atitle=TITLE"
