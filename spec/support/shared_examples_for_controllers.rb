RSpec.shared_examples 'authenticated' do
  context 'without authentication' do
    before { do_request }
    it { is_expected.to respond_with(:unauthorized) }
  end
end
