require 'net/ftp'
require 'csv'
require 'set'

module DtuCard
  class Base
    def filename
      File.expand_path("tmp/library_card_ids.csv", Rails.root)
    end 
  end

  class Fetch < Base
    REMOTE_FILE = 'Samlet-ADK.csv'

    attr_reader :errors

    def initialize
      @errors = []
    end

    def fetch_card_file
      dir = File.dirname(filename)
      Dir.mkdir(dir) unless File.directory? dir
      ftp = Net::FTP.open(config[:server], config[:user], config[:password])
      ftp.getbinaryfile(REMOTE_FILE, filename)
      ftp.close
    end

    def config
      Rails.application.config.dtu_card
    end
  end

  class Process < Base
    attr_reader :errors

    def initialize
      @errors = []
      @emails_seen = Set.new
    end

    def process(cardid, email)
      user = User.where(:email => email.downcase).first
      return if user.nil? 
      return unless ['dtu_empl', 'student'].include?(user.user_type.code)

      cardid_hex = cardid.to_i.to_s(16).upcase
      cardid_hex = "0#{cardid_hex}" if cardid_hex.size.odd?

      unless cardid_hex == user.librarycard
        if @emails_seen.include?(email)
          @errors << "Duplicate entry for #{email}"
        else
          user.librarycard = cardid_hex
          @errors << "Can't update #{email} with #{cardid}" unless user.save
        end
      end

      @emails_seen << email
    end

    def process_card_file
      CSV.parse(File.read(filename, :encoding => 'iso-8859-1'), :col_sep => ';') do |row|
        process(row[5], row[4]) unless row[4].blank?
      end
    end
  end
end
