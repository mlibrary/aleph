require 'net/ftp'
require 'csv'

module DtuCard
  class Base
    def filename
      File.expand_path("tmp/library_card_ids.csv", Rails.root)
    end 
  end

  class Fetch < Base
    REMOTE_FILE = 'Sagio/Samlet-ADK.csv'

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
      @starttime = Time.new
    end

    def process(cardid, email)
      user = User.where(:email => email.downcase).first
      return if user.nil? 
      return unless ['dtu_empl', 'student'].include?(user.user_type.code)
      if user.librarycard != cardid
        if user.updated_at < @starttime
          user.librarycard = cardid.to_i.to_s(16).upcase
          user.save || @errors << "Can't update #{email} with #{cardid}"
        else
          @errors << "Duplicate entry for #{email}"
        end
      end
    end

    def process_card_file
      CSV.parse(File.read(filename), :col_sep => ';') do |row|
        process(row[3], row[4]) unless row[4].blank?
      end
    end
  end
end
