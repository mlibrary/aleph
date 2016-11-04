require 'parallel'
require 'debugger'
require 'csv'
require 'pp'

class ExportField
  def initialize(header_name, getter)
    @header_name = header_name
    @getter = getter
  end

  def header_name
    @header_name
  end

  def value_for(entity)
    getter.call(entity)
  end

  private

  def getter
    @getter
  end
end

class FieldsToExport
  def initialize
    @export_fields = [
      ExportField.new("cardnumber", lambda { |entity| entity.librarycard }),
      ExportField.new("surname", lambda { |entity| entity.last_name }),
      ExportField.new("firstname", lambda { |entity| entity.first_name }),
      ExportField.new("initials", lambda { |entity| entity.initials }),
      ExportField.new("address", lambda { |entity| entity.formatted_address }),
      ExportField.new("address2", lambda { |entity| "" }), # TODO TLNI
      ExportField.new("city", lambda { |entity| entity.city_name }),
      ExportField.new("zipcode", lambda { |entity| entity.zipcode }),
      ExportField.new("country", lambda { |entity| entity.country }),
      ExportField.new("email", lambda { |entity| entity.email }),
      ExportField.new("phone", lambda { |entity| entity.phone }),
      ExportField.new("sex", lambda { |entity| entity.gender }),
      ExportField.new("dateofbirth", lambda { |entity| entity.formatted_birth_day }),
      ExportField.new("branchcode", lambda { |entity| entity.branchcode }),
      ExportField.new("categorycode", lambda { |entity| entity.categorycode }), # TODO TLNI
      ExportField.new("dateenrolled", lambda { |entity| "" }), # TODO TLNI
      ExportField.new("dateexpiry", lambda { |entity| "" }), # TODO TLNI
      ExportField.new("userid", lambda { |entity| "" }), # TODO TLNI
      ExportField.new("cpr", lambda { |entity| entity.cpr.blank? ? "" : entity.cpr[0..5] + "xxxx" }), # TODO TLNI
      ExportField.new("cwis", lambda { |entity| "" }), # TODO TLNI
      ExportField.new("snumber", lambda { |entity| "" }), # TODO TLNI
      ExportField.new("riyosha-id", lambda { |entity| "" }), # TODO TLNI
      ExportField.new("object", lambda { |entity| entity.to_json }), # TODO TLNI: Remove
      ExportField.new("expanded", lambda { |entity| entity.expanded.to_json }), # TODO TLNI: Remove
      ExportField.new("dtubase", lambda { |entity| entity.dtubase.to_json }), # TODO TLNI: Remove
    ]
  end

  def export_fields
    @export_fields
  end

  def header_names
    export_fields.collect { |ef| ef.header_name }
  end

  def values_for(entity)
    export_fields.collect { |ef| ef.value_for(entity) }
  end
end

namespace :brugerbasen do
  desc "Dump users"
  task :dump => :environment do
    #
    # Extend the DtuBase class with some helpful methods
    #
    DtuBase.class_eval do
      define_method(:get_phone_number, lambda do
        sms_phone = @account.xpath("@sms_phone").text
        private_phones  = @account.xpath("private_address[@is_secret_address='0']").collect { |private_address| [private_address.xpath("@phone1").text, private_address.xpath("@phone2").text, private_address.xpath("@phone3").text] }.flatten
        employee_phones = @account.xpath("profile_employee[@active='1']/address[@is_secret_address='0']").collect { |employee_address| [employee_address.xpath("@phone1").text, employee_address.xpath("@phone2").text, employee_address.xpath("@phone3").text] }.flatten
        student_phones = @account.xpath("profile_student[@active='1']/address[@is_secret_address='0']").collect { |student_address| [student_address.xpath("@phone1").text, student_address.xpath("@phone2").text, student_address.xpath("@phone3").text] }.flatten
        # TODO TLNI: Select just one phone number? Priority of these phone numbers?
        ([sms_phone] + private_phones + employee_phones + student_phones).reject { |p| p.blank? }.uniq.join(", ")
      end)
    end

    #
    # Extend the IllUsers class with some helpful methods
    #
    IllUser.class_eval do
      # TODO TLNI
      define_method(:cpr, lambda { "" })
      define_method(:initials, lambda { "" })
      define_method(:formatted_address, lambda { "" })
      define_method(:city_name, lambda { "" })
      define_method(:zipcode, lambda { "" })
      define_method(:country, lambda { "" })
      define_method(:phone, lambda { "" })
      define_method(:sex, lambda { "" })
      define_method(:formatted_birth_day, lambda { "" })
      define_method(:branchcode, lambda { "" })
      define_method(:categorycode, lambda { "LIB" })
      define_method(:dtubase, lambda { "" })

      define_method(:expanded, lambda { @expanded })
    end

    #
    # Extend the User class with some helpful methods
    #
    User.class_eval { define_method(:dtubase, lambda { @dtubase }) } unless User.class_eval { method_defined?(:dtubase) }
    User.class_eval { define_method(:cpr, lambda { (@dtubase || Struct.new(:cpr).new(nil)).cpr || local_cpr }) } unless User.class_eval { method_defined?(:cpr) }
    User.class_eval { define_method(:formatted_birth_day, lambda { return "" if birth_day.blank?; return "#{birth_day[0..3]}-#{birth_day[4..5]}-#{birth_day[6..7]}" }) } unless User.class_eval { method_defined?(:formatted_birth_day) }
    User.class_eval { define_method(:initials, lambda { ((@expanded || {})[:dtu] || {})["initials"] || "" }) } unless User.class_eval { method_defined?(:initials) }
    User.class_eval { define_method(:formatted_address, lambda { ((@expanded || {})[:address] || Struct.new(:attributes).new({})).attributes.select { |k,v| /^line/.match(k) }.values.reject { |v| v.blank? }.join("\n").gsub(/<div style="display:none">wer54w66sf32re2<\/div>/, "") }) } unless User.class_eval { method_defined?(:formatted_address) }
    User.class_eval { define_method(:city_name, lambda { ((@expanded || {})[:address] || Struct.new(:cityname).new("")).cityname.gsub(/<div style="display:none">wer54w66sf32re2<\/div>/, "") }) } unless User.class_eval { method_defined?(:city_name) }
    User.class_eval { define_method(:zipcode, lambda { ((@expanded || {})[:address] || Struct.new(:zipcode).new("")).zipcode.gsub(/<div style="display:none">wer54w66sf32re2<\/div>/, "") }) } unless User.class_eval { method_defined?(:zipcode) }
    User.class_eval { define_method(:country, lambda { ((@expanded || {})[:address] || Struct.new(:country).new("")).country.gsub(/<div style="display:none">wer54w66sf32re2<\/div>/, "") }) } unless User.class_eval { method_defined?(:country) }

    # TODO TLNI: Is this enough? (What about "Aqua" in Charlottenlund ...?)
    User.class_eval { define_method(:ballerup?, lambda { (((@expanded || {})[:dtu] || {})["org_units"] || []).include?("IHK") }) } unless User.class_eval { method_defined?(:ballerup?) }
    User.class_eval { define_method(:lyngby?, lambda { not (((@expanded || {})[:dtu] || {})["org_units"] || []).include?("IHK") }) } unless User.class_eval { method_defined?(:lyngby?) }
    User.class_eval { define_method(:branchcode, lambda { return "DTV" if lyngby?; return "BAL" if ballerup?; return "" }) } unless User.class_eval { method_defined?(:branchcode) }

    unless User.class_eval { method_defined?(:categorycode) }
      User.class_eval do
        define_method(:categorycode, lambda do
          null_account = Object.new; null_account.define_singleton_method(:xpath, lambda { |_| [] })
          return "STAFF" if (((@dtubase || Struct.new(:account).new(nil)).account) || null_account).xpath("profile_employee[@active='1']/@fk_orgunit_id").collect { |a| a.text }.any? { |orgunit| ["Myndig", "58"].include?(orgunit) }
          return "EMPL" if (((@expanded || {})[:dtu] || {})["user_type"] || "") == "dtu_empl"
          return "STUD" if [((@expanded || {})[:user_type] || ""), (((@expanded || {})[:dtu] || {})["user_type"] || "")].include?("student")
          return "PRIV" if [((@expanded || {})[:user_type] || ""), (((@expanded || {})[:dtu] || {})["user_type"] || "")].include?("private")
          return ""
        end)
      end
    end

    User.class_eval { define_method(:phone, lambda { (@dtubase || Struct.new(:get_phone_number).new("")).get_phone_number }) } unless User.class_eval { method_defined?(:phone) }
    User.class_eval { define_method(:expanded, lambda { @expanded }) } unless User.class_eval { method_defined?(:expanded) }

    # Optimize (use eager loaded identity) and add a null check
    User.class_eval do
      alias_method(:old_do_expand_user, :do_expand_user)
      define_method(:do_expand_user, lambda do
        @expanded = as_json
        @expanded[:user_type] = user_type.code
        if dtu_affiliate?
          ident = identities.select { |i| i.provider == "dtu" }.first
          expand_dtu ident.uid unless ident.nil?
        else
          expand_local
        end
        @expanded
      end)
    end

    fields_to_export = FieldsToExport.new
    #
    # User (CSV)
    #
    query = "current_sign_in_at >= NOW() - interval '2 year'"
    entities = []
    entities.concat(IllUser.eager_load(:address).all.shuffle[0..20])
    entities.concat(User.where(query).eager_load(:user_type, :identities).shuffle[0..280])

    #count = 0
    mutex = Mutex.new
    Parallel.each(entities, in_threads: 4) do |entity|
      begin
        entity.expand
      rescue Exception => e
        mutex.synchronize do
          STDERR.puts "Exception caught while expanding entity: #{e.class} #{e.message}\n\n  User:\n  #{PP.pp(entity, '')}\n  Backtrace:\n  #{e.backtrace.join("\n  ")}\n\n"
        end
      end

      #mutex.synchronize do
      #  count = count + 1
      #  puts "#{DateTime.now.strftime('%s')} #{count} #{entity.id}"
      #end
    end

    out = CSV.generate(headers: true) do |csv|
      csv << fields_to_export.header_names

      entities.each do |entity|
        begin
          csv << fields_to_export.values_for(entity)
        rescue Exception => e
          STDERR.puts "Exception caught while generating CSV: #{e.class} #{e.message}\n\n  User:\n  #{PP.pp(entity, '')}\n  Backtrace:\n  #{e.backtrace.join("\n  ")}\n\n"
        end
      end
    end

    puts out
  end
end
