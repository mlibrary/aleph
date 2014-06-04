
class Address < ActiveRecord::Base
  SKIP_COUNTRY_VALUES = [ 'DK', 'DANMARK' ]

  attr_accessible :cityname, :country, :line1, :line2, :line3, :line4,
    :line5, :line6, :zipcode

  validates :line1, :presence => true
  validates :line2, :presence => true
  validates :zipcode, :presence => true
  validates :cityname, :presence => true

  def to_hash
    values = Hash.new
    %w(line1 line2 line3 line4 line5 line6 zipcode cityname
       country).each do |k|
      values[k] = send(k)
    end
    values
  end

  def <<(value)
    @index ||= 1
    if @index < 7
      self.send("line#{@index}=", value)
      @index += 1;
    end
  end

  def name
    "#{line1}, #{line2}, #{zipcode} #{cityname}"
  end

  def to_a
    line7 = SKIP_COUNTRY_VALUES.include?(country) ? "" : "#{country}-"
    line7 << "#{zipcode} #{cityname}"
    [line1, line2, line3, line4, line5, line6, line7].compact
  end

  def each
    to_a.each do |x|
      yield x unless x.blank?
    end
  end

  def self.delete_orphaned
    Address.where([
        
      ])
  end

end
