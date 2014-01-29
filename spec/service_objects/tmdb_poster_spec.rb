describe TmdbPoster do
  describe '#uri' do
    subject(:uri) { TmdbPoster.new(file_path: file_path).uri }

    let(:file_path)     { '/filenameforposter.jpg' }
    let(:config_double) { double('config', secure_base_url: 'https://image.tmdb.org/t/p/') }

    before do
      expect(Tmdb::Configuration).to receive(:new).and_return(config_double)
    end

    it { should be_a(URI::HTTPS) }
    it { should eq(URI.parse('https://image.tmdb.org/t/p/original/filenameforposter.jpg')) }
  end
end
