module ActiveAdmin::UserHelper

  def formatted_aleph_data(user)
    aleph_data = Aleph::Borrower.new.lookup_all(user)
    CodeRay.scan(aleph_data.ai(:plain => true), :ruby).div(:css => :style)
  end

  def formatted_dtubase_data(user)
    account = DtuBase.lookup_xml(:cwis => user.expand[:dtu]['matrikel_id'])
    CodeRay.scan(format_xml_attributes(account), :xml).div(:css => :style)
  end

  def format_xml_attributes(xml)
    lines = []

    xml.lines.map { |line|
      line.gsub %r{(\s*)<(\S+\s+)(.*?)/?>} do
        spaces = $1
        name   = $2
        attrs  = $3.split /"\s/

        out = spaces
        out += '<' + name

        attr_line = ''
        attrs.each do |attr|
          last = attr === attrs.last
          attr_line += attr + ((last && attr[-1] == '"') ? '' : '"')
          unless last
            if attr_line.length > 100
              out += attr_line + "\n"
              attr_line = spaces + ' ' * (name.length + 1)
            else
              attr_line += ' '
            end
          end
        end

        out += attr_line + '>'
      end
    }.join
  end

end
