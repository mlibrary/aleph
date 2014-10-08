module Aleph
  class Borrower < Base

    def initialize
      @@connection = Aleph::Connection.instance
      @adm_library ||= config.adm_library
      if @adm_library.blank?
        raise Aleph::Error, "ADM library must be specified in configuration" 
      end

    end

    #   Update aleph user from riyosha user
    def update_user(user)
      @user_id = "#{config.bor_prefix}-#{user.cas_username}"
      z303, z304, z305, z308 = information_from_user_object(user)
      if aleph_full_lookup(z308)
        if config.create_aleph_borrowers
          if @aleph_pid.blank?
            bor_new('I', z303, z304, z305, z308)

            @aleph_pid = aleph_lookup(z308[0])
            if @aleph_pid.blank?
              logger.error "No aleph id returned for #{@user_id}"
              raise Aleph::Error, "Borrower could not be created in ALEPH"
            end
          else
            aleph_update(z303, z304, z305, z308)
          end
          logger.info "PID #{@aleph_pid}"
        end
      elsif try_to_fix_non_matching_aleph_ids(user)
        z303, z304, z305, z308 = information_from_user_object(user)
        if aleph_full_lookup(z308)
          aleph_update(z303, z304, z305, z308)
          logger.info "PID #{@aleph_pid}"
        else
          msg = "Still non matching ALEPH ids after trying to fix"
          msg += "\n" + Aleph::Borrower.new.lookup_all(user).ai(:plain => true)
          msg += "\n" + user.ai(:plain => true)
          logger.error msg
        end
      else
        @aleph_pid = nil
        msg = "Non matching ALEPH ids"
        msg += "\n" + Aleph::Borrower.new.lookup_all(user).ai(:plain => true)
        msg += "\n" + user.ai(:plain => true)
        logger.error msg
      end
    end

    def try_to_fix_non_matching_aleph_ids(user)
      aleph_data = lookup_all(user)
      
      if library_card_is_the_only_key_on_wrong_account(user, aleph_data)
        return reset_library_card_on_wrong_account(user, aleph_data)
      end
      
      return false
    end

    def library_card_is_the_only_key_on_wrong_account(user, aleph_data)
      library_card_pid = aleph_data[:pids][['01', user.librarycard]]
      return !library_card_pid.blank? && aleph_data[:pids].values.count(library_card_pid) == 1
    end

    def reset_library_card_on_wrong_account(user, aleph_data)
      library_card_pid = aleph_data[:pids][['01', user.librarycard]]
      new_barcode = "ri#{SecureRandom.hex(4)}"
      logger.warn "Trying to fix non-matching ALEPH ids by resetting code 01 id '#{user.librarycard}' from #{library_card_pid}"
      xml = %{<?xml version="1.0"?><p-file-20><patron-record><z303><record-action>X</record-action><match-id-type>00</match-id-type><match-id>#{library_card_pid}</match-id></z303><z308><z308-key-type>01</z308-key-type><z308-key-data>#{new_barcode}</z308-key-data><record-action>I</record-action></z308></patron-record></p-file-20>}

      return @@connection.x_request('update_bor', {
          :update_flag => 'Y', :library => 'DTV50', :xml_full_req => xml
        }).success
    end

    def lookup_all(user)
      z303, z304, z305, z308s = information_from_user_object(user)
      pids = {}
      info = {}
      logger.debug "Generated aleph keys: #{z308s}"
      z308s.each do |z308|
        logger.debug "bor_by_key for #{z308}"
        pid = aleph_lookup(z308)
        logger.debug "pid found: #{pid}"
        pids[[z308['z308-key-type'],z308['z308-key-data']]] = pid
        if !pid.blank? 
          logger.debug "bor_info for pid #{pid}"
          info[pid] = Hash.from_xml(bor_info(pid).to_xml)
          info[pid] = abbrev_aleph_info(info[pid]) if info[pid]
        end
      end
      return {:pids => pids, :info => info }
    end

    def abbrev_aleph_info(info)
      { 
        'z303' => info['bor_info']['z303'].slice('z303_id', 'z303_open_date', 'z303_update_date', 'z303_update_date'),
        'z304' => info['bor_info']['z304'].slice('z304_address_0', 'z304_address_1', 'z304_address_2', 'z304_address_3', 'z304_email_address', 'z304_update_date'),
        'z305' => info['bor_info']['z305'].slice('z305_bor_type', 'z305_bor_status', 'z305_update_date'),
      }
    end
    

    def valid_aleph_bor?
      !@aleph_pid.blank?
    end

    def bor_info(pid)
      raise Aleph::Error, "Borrower not set" if pid.blank?
      raise Aleph::Error, "ADM library not set" if @adm_library.blank?

      document = @@connection.x_request('bor_info', {
        'library' => @adm_library,
        'bor_id' => pid,
        'loans' => 'N',
        'cash' => 'N',
        'hold' => 'N',
        'translate' => 'N',
      }).success

      @z303 = parse(document.xpath('//z303'))[0]
      @z304 = parse(document.xpath('//z304'))[0]
      @z305 = parse(document.xpath('//z305'))[0]
      document
    end

    def global
      @z303
    end

    def address
      @z304
    end

    def local
      @z305
    end


    #protected


    def aleph_lookup(z308)
      result = @@connection.x_request('bor_by_key', {
        'library' => @adm_library,
        'bor_type_id' => z308['z308-key-type'],
        'bor_id' => z308['z308-key-data'],
      }).document
      result.xpath('//internal-id').text
    end

    def aleph_full_lookup(z308s)
      @aleph_pid = nil
      identical = true
      z308s.each do |z|
        pid = aleph_lookup(z)
        if pid.blank?
          z['empty'] = true
        else
          @aleph_pid ||= pid
          identical = false unless pid == @aleph_pid
        end
      end
      identical
    end

    def aleph_update(z303, z304, z305, z308)
      bor_info(@aleph_pid)
      if check_for_updates(z303, z304, z305, z308)
        bor_update('U', @z303, @z304, @z305, @z308) 
      end
    end

    def check_for_updates(z303, z304, z305, z308)
      update = update_bor_part(@z303, z303)
      # We only get one z304 record (current address)
      # Either update it or removed it if not type 01
      if @z304['z304-address-type'] == '01'
        update = update_bor_part(@z304, z304) || update
      elsif @z304['z304-id'].blank?
        update = update_bor_part(@z304, z304) || update
        @z304['record-action'] = 'I'
      else 
        @z304['record-action'] = 'D'
        update = true
      end
      # We might get the master Z305 (sub-library = ALEPH) which can't be
      # updated. Create a new Z305 in that case.
      if @z305 and @z305['z305-sub-library'] != 'ALEPH'
        if @z305['z305-registration-date'] == '00000000'
          @z305['z305-registration-date'] = nil
        end
        update = update_bor_part(@z305, z305) || update
      else
        @z305 = z305
        @z305['record-action'] = 'I'
        update = true
      end
      @z308 = Array.new
      z308.each do |z|
        if z['empty']
          z.delete('empty')
          z['record-action'] = 'I'
          fill_defaults z, config.z308_defaults
          @z308 << z
          update = true
        end
      end
      update
    end

    def update_bor_part(current, new)
      update = false
      new.each do |k, v|
        if current[k] != v
          update = true
          current[k] = v
        end
      end
      update
    end

    def bor_new(action, z303, z304, z305, z308)
      fill_defaults z303, config.z303_defaults
      fill_defaults z304, config.z304_defaults
      fill_defaults z305, config.z305_defaults

      z308.each do |z|
        fill_defaults z, config.z308_defaults
      end
      bor_update(action, z303, z304, z305, z308)
    end

    def bor_update(action, z303, z304, z305, z308)
      today = Time.new.strftime("%Y%m%d")

      z303['record-action'] ||= action
      if @aleph_pid.blank?
        z303['match-id-type'] = config.bor_type_id
        z303['match-id'] = @user_id
      else
        z303['match-id-type'] = '00'
        z303['match-id'] = @aleph_pid
      end
      %w(z303-id z303-name-key z303-open-date z303-update-date
         z303-upd-time-stamp).each do |k|
        z303.delete(k)
      end

      unless z304.nil?
        z304['record-action'] ||= action
        unless action == 'D'
          z304['z304-date-from'] ||= today
          z304['z304-date-to'] ||= config.z304_defaults['z304-date-to']
        end
      end

      unless z305.nil?
        z305['record-action'] ||= action
        z305['z305-registration-date'] ||= today
        %w(z305-open-date z305-update-date z305-upd-time-stamp).each do |k|
          z305.delete(k)
        end
      end

      if @aleph_pid
        z308 << {
          'z308-key-type'     => '00',
          'z308-key-data'     => @aleph_pid,
          'z308-verification' => @aleph_pid,
        }
      end

      z308.each do |z|
        z['record-action'] ||= action
        z['z308-verification'] ||= random_pin
      end

      builder = Nokogiri::XML::Builder.new do |xml|
        xml.send(:"p-file-20") do
          xml.send(:"patron-record") do
            xml.z303 { z303.each { |k, v| xml.send(k, v) } }
            xml.z304 { z304.each { |k, v| xml.send(k, v) } } unless z304.nil?
            xml.z305 { z305.each { |k, v| xml.send(k, v) } } unless z305.nil?
            z308.each do |z|
              xml.z308 { z.each { |k, v| xml.send(k, v) } }
            end
          end
        end
      end
      request = builder.to_xml(:indent => 0).gsub("\n", '')
      response = @@connection.x_request('update-bor',
        'update_flag' => 'Y',
        'library' => @adm_library,
        'xml_full_req' => request
      ).success
    end

    def information_from_user_object(user)
      z303 = {
        'z303-name' => "#{user.last_name}, #{user.first_name}",
        'z303-gender' => '',
      }
      if user.respond_to? :gender
        z303['z303-gender'] = user.gender
      end
      if user.respond_to? :aleph_home_library
        z303['z303-home-library'] = user.aleph_home_library
      end
      z304 = {
        'z304-address-type' => '01',
        'z304-zip' => '',
        'z304-email-address' => user.email,
        'z304-telephone' => '',
      }
      if user.respond_to? :telephone
        z304['z304-telephone'] = user.telephone
      end
      n = 0
      user.address_lines.each do |a|
        if n <= 4
          field = format("z304-address-%d", n)
          z304[field] = a
        end
        n += 1
      end
      aleph_types = user.aleph_bor_status_type
      z305 = {
        'z305-sub-library' => @adm_library,
        'z305-bor-status' => format("%02d", aleph_types[0].to_i),
        'z305-bor-type' => format("%02d", aleph_types[1].to_i),
        'z305_loan_check' => 'Y',
      }
      # Create z308s
      z308 = Array.new
      z308 << {
        'z308-key-type' => config.bor_type_id,
        'z308-key-data' => "#{config.bor_prefix}-#{user.cas_username}X"
      }
      if user.respond_to? :aleph_ids
        user.aleph_ids.each do |id|
          z308 << {
            'z308-key-type' => id['type'],
            'z308-key-data' => id['id'],
            'z308-verification' => id['pin'],
          }
        end
      end
      [z303, z304, z305, z308]
    end

    def fill_defaults(object, defaults)
      defaults.each do |k, v|
        if object[k] == nil
          object[k] = v
        end
      end
    end

    def random_pin
      SecureRandom.base64(8)
    end
  end
end
