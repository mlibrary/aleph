require 'dtu_card'

namespace :dtu_card do
  desc "Update chip-card data from card database"
  task :update => :environment do
    fetcher = DtuCard::Fetch.new
    fetcher.fetch_card_files
    fetcher.errors.each do |error|
      puts error
    end

    process = DtuCard::Process.new 
    process.process_files
    process.errors.each do |error|
      puts error
    end
  end

end
