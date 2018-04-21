# frozen_string_literal: true

require_relative '../spec_helper'

describe Aleph::Borrower do
  describe '#bor_info' do
    it 'Gets the borrower information' do
      subject.bor_info('bertrama')
      expect(subject.local['z305-sub-library']).to eq('MIU50')
    end
  end

  describe '#type' do
    it "Returns the borrower's type" do
      subject.bor_info('bertrama')
      expect(subject.type).to eq('ST')
    end
  end

  describe '#status' do
    it "Returns the borrower's status" do
      subject.bor_info('bertrama')
      expect(subject.status).to eq('02')
    end
  end

  describe '#expired?' do
    it "Returns whether the borrow's account is expired" do
      subject.bor_info('bertrama')
      expect(subject.expired?).to be(false)
    end
  end

  describe '#profile_id' do
    it 'Returns the campus' do
      subject.bor_info('bertrama')
      expect(subject.profile_id).to eq('UMAA')
    end
  end
end
