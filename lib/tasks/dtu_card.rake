require 'dtu_card'

namespace :dtu_card do
  desc "Fetch chip-card data from card database"
  task :fetch => :environment do
    fetcher = DtuCard::Fetch.new
    fetcher.fetch_card_file
    fetcher.errors.each do |error|
      puts error
    end
  end

  desc "Update chip-card data from fetched files"
  task :update => :environment do
    process = DtuCard::Process.new 
    process.process_card_file
    process.errors.each do |error|
      puts error
    end
  end

  desc 'Fix card ids with odd number of characters'
  task :fix_cardids => :environment do
    User.all.each do |u|
      if u.librarycard && u.librarycard.size.odd?
        u.librarycard = "0#{u.librarycard}"
        u.save
      end
    end
  end
end
