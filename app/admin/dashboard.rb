ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: "Dashboard"

  content title: "Dashboard" do
    # From https://github.com/activeadmin/activeadmin/wiki/How-to-display-the-version-tag-and-commit-hash-of-the-currently-deployed-source-on-the-dashboard
    panel "Currently deployed" do
      link_title = `git log --max-count=1 --pretty=format:"%h (%ar): %s"`
      #latest_tag = `git describe --tags --abbrev=0` # if we start using git version tags
      commit_hash = `git log --skip=100 --max-count=1 --pretty=format:"%H"`
      # Faked most recent live commit_hash, because local is ahead of origin/upsteam/prod.
      # Replace with the uncommented line if we decide to do this.
      #commit_hash = `git rev-parse HEAD`
      para <<-EOL.html_safe
        Most recent commit: #{link_to(link_title,
        "https://github.com/calacademy/antcat/commit/#{commit_hash}")}
      EOL
    end

    # From https://github.com/activeadmin/activeadmin/wiki/Auditing-via-paper_trail-(change-history)
    section "Recent changes [WIP, currently not very useful]" do
      table_for PaperTrail::Version.order('id desc').limit(20) do
        column("Item") { |v| v.item }
        column("Type") { |v| v.item_type.underscore.humanize }
        column("Modified at") { |v| v.created_at.to_s :long }
        column "User" do |v|
          link_to User.find(v.whodunnit).email, [:admin, User.find(v.whodunnit)]
        end
      end
    end

  end # content
end
