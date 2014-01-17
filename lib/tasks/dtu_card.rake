require 'dtu_card'

namespace :dtu do
  desc "Fetch files with access card numbers"
  task :fetchcard => :environment do
    fetcher = DtuCard::Fetch.new
    fetcher.fetch_card_files
    fetcher.errors.each do |error|
      puts error
    end
  end

  desc "Process files with access card numbers"
  task :card => :fetchcard do
    process = DtuCard::Process.new 
    process.process_files
    process.errors.each do |error|
      puts error
    end
  end
end
