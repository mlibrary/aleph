require 'net/ftp'
require 'csv'

module DtuCard
  class Base
    def employee_file_name
      File.expand_path("files/employee.csv", Rails.root)
    end 

    def student_file_name
      File.expand_path("files/student.csv", Rails.root)
    end
  end

  class Fetch < Base
    attr_reader :errors

    def initialize
      @errors = Array.new
    end

    def fetch_card_files
      ftp = Net::FTP.open(config[:server], config[:user], config[:password])
      dir = File.dirname(employee_file_name)
      Dir.mkdir(dir) unless File.directory? dir
      ftp.getbinaryfile('Card8000-ansatte.csv', employee_file_name)
      ftp.getbinaryfile('card8000.csv', student_file_name)
      ftp.close
    end

    def config
      Rails.application.config.dtu_card
    end
  end

  class Process < Base
    attr_reader :errors

    def initialize
      @errors = Array.new
      @starttime = Time.new
    end

    def process(cardid, email)
      cardid = format("%x", cardid)
      record = User.where(:email => email.downcase).first
      return if record.nil?
      if record.librarycard != cardid
        if record.updated_at < @starttime
          record.librarycard = cardid
          record.save || @errors << "Can't update #{email} with #{cardid}"
        else
          @errors << "Duplicate entry for #{email}"
        end
      end
    end

    def process_employee
      # Row format: Firstname, Lastname, Initials, Cardid, Email
      CSV.parse(File.read(employee_file_name), :col_sep => ';') do |row|
        process(row[3], row[4]) unless row[4].blank?
      end
    end

    def process_student
      # Row format: Firstname, Lastname, Student ID/Initials, Cardid, CPR, Email
      CSV.parse(File.read(student_file_name), :col_sep => ';') do |row|
        process(row[3], row[5]) unless row[5].blank?
      end
    end

    def process_files
      process_employee
      process_student
    end

  end
end
