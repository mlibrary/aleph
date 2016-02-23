class VipBase
  
  def self.fetch
    if config[:stub]
      result = stubbed_request
    else      
      result = sru_request
    end
    result.map { |r| Branch.new(r.elements['vip:metadata']) }.select{|b| ['H', 'f', 'P', 'DELETED'].include? b.record_type }
  end

  

  class Branch
    attr_reader :library_id, :email, :name, :address, :zip, :city, :phone, :type, :record_type
    
    def initialize(element)
      @element     = element
      @library_id  = get_text('vip:branchId')
      @email       = get_text('vip:branchEmail') || get_text('vip:libraryEmail') || get_text('vip:answerEmail')
      @name        = get_text('vip:branchName')
      @address     = get_text('vip:address')
      @zip         = get_text('vip:postalCode')
      @city        = get_text('vip:city')
      @phone       = get_text('vip:branchPhone')
      @type        = get_text('vip:libraryType')
      @record_type = get_text('vip:branchType')
    end
    
    def deleted?
      record_type == 'DELETED'
    end

    private 

    def get_text(xpath) 
      @element.elements[xpath].try(:text)
    end

    def has_element(xpath)
      @element.elements[xpath]
    end

  end

  private 

  def self.sru_request
    client = SRU::Client.new(config[:url])
    empty_result = client.search_retrieve(
      "dc.type = (*) and dc.date >= (#{config[:earliest]})",
      :version        => '1.1',
      :maximumRecords => 0,
      :startRecord    => 1,
      :recordSchema   => 'vip',
      :recordPacking  => 'string',
      :stylesheet     => 'default.xsl')

    number_of_records = empty_result.number_of_records

    result = client.search_retrieve(
      "dc.type = (*) and dc.date >= (#{config[:earliest]})",
      :version        => '1.1',
      :maximumRecords => number_of_records,
      :startRecord    => 1,
      :recordSchema   => 'vip',
      :recordPacking  => 'string',
      :stylesheet     => 'default.xsl')
  end

  def self.stubbed_request
    doc = REXML::Document.new(File.read(config[:stub_file]))
    SRU::SearchResponse.new(doc, 'rexml')
  end

  def self.config
    Rails.application.config.vip_base
  end
end
