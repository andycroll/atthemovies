require 'rails_helper'

describe DestroyPastScreenings do
  describe '#perform' do
    subject(:perform) { described_class.new.perform }

    it 'removes past screenings' do
      expect(Screening).to receive_message_chain(:past, :destroy_all)
      perform
    end
  end
end
