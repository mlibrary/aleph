require 'utility'

module Concerns
  module AlephUser
    extend ActiveSupport::Concern

    def aleph_borrower
      if show_feature?(:aleph)
        begin
          @aleph ||= Aleph::Borrower.new(self) if may_lend_printed?
        rescue => e
          Utility.log_exception e, :info => "Could not update Aleph for user #{self.inspect}"
        end
      end
    end
    
    def aleph_bor_status_type
      expand
      return [aleph_bor_status, aleph_bor_type]
    end


    def aleph_ids
      expand
      # Create additional ids
      ids = Array.new

      ids << { 'type' => '03',
        'id' => "DTU#{@cpr}",
        'pin'  => nil,
      } if self.user_type.code == 'dtu_empl'

      ids << { 'type' => '03',
        'id' => "STUD#{@cpr}",
        'pin'  => nil,
      } if self.user_type.code == 'student'

      ids << { 'type' => '03',
        'id' => library_id,
        'pin'  => nil,
      } if self.user_type.code == 'library'

      ids << { 'type' => '03',
        'id' => @cpr,
        'pin'  => nil,
      } if self.user_type.code == 'private'

      ids << { 'type' => '03',
        'id' => @expanded[:dtu]['initials'].upcase,
        'pin'  => nil,
      } if @expanded[:dtu] && !@expanded[:dtu]['initials'].blank?

      ids << { 'type' => '03',
        'id' => "CWIS#{@expanded[:dtu]['matrikel_id']}",
        'pin'  => nil,
      } if @expanded[:dtu] && !@expanded[:dtu]['matrikel_id'].blank?

      ids << { 'type' => '01',
        'id' => librarycard,
        'pin' => nil,
      } unless librarycard.blank?

      ids
    end

    def address_lines
      expand
      @expanded[:address] ? @expanded[:address].to_a : Array.new
    end

    def aleph_bor_status
      (user_sub_type.nil? ? nil : user_sub_type.aleph_bor_status) ||
        user_type.aleph_bor_status
    end

    def aleph_bor_type
      (user_sub_type.nil? ? nil : user_sub_type.aleph_bor_type) ||
        user_type.aleph_bor_type
    end


  end
end
