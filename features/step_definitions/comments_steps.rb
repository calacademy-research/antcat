# frozen_string_literal: true

def i_write_a_new_comment body
  first("#comment_body").set body
end

def batiatus_has_commented_cool_on_an_issue_with_the_title_typos
  issue = create :issue, title: "Typos"
  user = User.find_by!(name: "Batiatus")
  Comment.build_comment(issue, user, body: "Cool").save!
end
