class Views::AutofillDemos::Index < Views::Base
  def container_content
    jquery '
      var availableTags = ["c++", "java", "php", "coldfusion", "javascript", "asp", "ruby", "python", "c", "scala", "groovy", "haskell", "perl"];
      $("#autofill").autocomplete({
          source: "/autofill_demos/names"
      });
    '

    input :id => 'autofill'
  end
end
