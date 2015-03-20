require 'rails_helper'

describe Films::FetchBackdrop do
  let(:job)  { described_class.new.perform(film) }
  let(:film) { create(:film, backdrop_source_uri: 'backdrop_url.jpg') }

  describe '#perform' do
    let(:uploader) { instance_double(ImageUploader, store: 'RETURN_URL') }

    Timecop.freeze do
      it 'remove the old backdrop and stores the film backdrop' do
        expect(film).to receive(:update_attributes).with(backdrop: 'RETURN_URL')
        expect(ImageUploader).to receive(:new)
          .with(width: 800,
                height: 450,
                url: 'backdrop_url.jpg',
                file_name: "backdrops/#{film.name.to_url}-#{film.year}/800x450-#{Time.now.strftime('%Y%m%d%H%M%S')}")
          .and_return(uploader)

        job
      end
    end
  end
end
