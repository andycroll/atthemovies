# frozen_string_literal: true
describe ExternalFilm::Backdrop do
  describe '#uri' do
    subject(:uri) { described_class.new(file_path).uri }

    let(:file_path)     { '/filenameforbackdrop.jpg' }
    let(:config_double) { double('config', secure_base_url: 'https://image.tmdb.org/t/p/') }

    before do
      expect(Tmdb::Configuration).to receive(:new).and_return(config_double)
    end

    it { is_expected.to be_a(URI::HTTPS) }
    it { is_expected.to eq(URI.parse('https://image.tmdb.org/t/p/original/filenameforbackdrop.jpg')) }
  end
end
