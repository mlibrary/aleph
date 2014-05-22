module Aleph
  class Borrower < Base
    # initialize(user)
    #   Setup an aleph borrower from user object
    #
    def initialize(user)
      @@connection = Aleph::Connection.instance
      @adm_library ||= config.adm_library
      if @adm_library.blank?
        raise Aleph::Error, "ADM library must be specified in configuration" 
      end

      @user_id = "#{config.bor_prefix}-#{user.id}"
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
      else
        @aleph_pid = nil
        msg = "Non matching ALEPH ids"
        z308.each do |z|
          msg += " #{z['z308-key-type']} - #{z['z308-key-data']}."
        end
        logger.error msg
      end
    end

    def valid_aleph_bor?
      !@aleph_pid.blank?
    end

    def bor_info
      raise Aleph::Error, "Borrower not set" if @aleph_pid.blank?
      raise Aleph::Error, "ADM library not set" if @adm_library.blank?

      document = @@connection.x_request('bor_info', {
        'library' => @adm_library,
        'bor_id' => @aleph_pid,
        'loans' => 'N',
        'cash' => 'N',
        'hold' => 'N',
        'translate' => 'N',
      }).success

      @z303 = parse(document.xpath('//z303'))[0]
      @z304 = parse(document.xpath('//z304'))[0]
      @z305 = parse(document.xpath('//z305'))[0]
      @loans = parse_group_objects( document.xpath("//item-l") )
      @holds = parse_group_objects( document.xpath("//item-h") )
      @cash = parse_group_objects( document.xpath("//fine") )
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


    protected


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
      bor_info
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
      response = @@connection.x_request('update-bor',
        'update_flag' => 'N',
        'library' => @adm_library,
        'xml_full_req' => builder.to_xml(:indent => 0).gsub("\n", '')
      ).document
      errors = Array.new
      response.xpath("//error").each do |e|
        errors << e.text unless e.text =~ /^Succeeded /
      end
      if errors.size > 0
        logger.error "Aleph update_bor failed with: #{errors.inspect}"
      end
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
        z303['z304-telephone'] = user.telephone
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
      }
      # Create z308s
      z308 = Array.new
      z308 << {
        'z308-key-type' => config.bor_type_id,
        'z308-key-data' => "#{config.bor_prefix}-#{user.id}"
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
