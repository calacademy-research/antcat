# coding: UTF-8
namespace :references do
  desc 'Check URLs'
  task :check_urls => :environment do
    Progress.init
    references_with_documents_count = error_count = 0
    Reference.all.each do |reference|
      Progress.tally
      next unless reference.document && reference.document.hosted_by_us?
      references_with_documents_count += 1
      begin
        reference.document.actual_url
      rescue Exception => e
        Progress.puts e.inspect
        Progress.puts "#{reference.id} #{reference.document.id} #{reference.document.url}"
        error_count += 1
      end
    end
    Progress.show_results
    Progress.show_count references_with_documents_count, Progress.processed_count, "with documents"
    Progress.show_count error_count, references_with_documents_count, "of those with documents, not found"
  end
end
