require 'dtu_card'

namespace :dtu_card do
  desc "Fetch chip-card data from card database"
  task :fetch => :environment do
    fetcher = DtuCard::Fetch.new
    fetcher.fetch_card_files
    fetcher.errors.each do |error|
      puts error
    end
  end

  desc "Update chip-card data from fetched files"
  task :update => :environment do
    process = DtuCard::Process.new 
    process.process_files
    process.errors.each do |error|
      puts error
    end
  end

end
