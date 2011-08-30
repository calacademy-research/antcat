# coding: UTF-8
desc 'Find duplicate references'
task :find_duplicate_references => :environment do
  DuplicateReferencesFinder.new(true).find_duplicates
end

namespace :references do
  desc 'Check URLs'
  task :check_urls => :environment do
    Progress.init true
    references_with_documents_count = error_count = 0
    Reference.all.each do |reference|
      Progress.tally_and_show_progress 10
      next unless reference.document
      references_with_documents_count += 1
      reference.document.check_url
      if reference.document.errors.present?
        Progress.puts reference.document.url
        Progress.puts reference.document.errors
        error_count += 1
      end
    end
    Progress.show_results
    Progress.show_count references_with_documents_count, Progress.processed_count, "with documents"
    Progress.show_count error_count, references_with_documents_count, "of those with documents, not found"
  end
end
