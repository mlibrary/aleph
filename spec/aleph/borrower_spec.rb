require_relative '../spec_helper'

describe Aleph::Borrower do
  describe '#bor_info' do
    it 'Gets the borrower information' do
      subject.bor_info('bertrama')
      expect(subject.local['z305-sub-library']).to eq('MIU50')
    end
  end
end
