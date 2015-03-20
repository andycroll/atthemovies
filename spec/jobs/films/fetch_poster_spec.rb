require 'rails_helper'

describe Films::FetchPoster do
  let(:job)  { described_class.new.perform(film) }
  let(:film) { create(:film, poster_source_uri: 'poster_url.jpg') }

  describe '#perform' do
    let(:uploader) { instance_double(ImageUploader, store: 'RETURN_URL') }

    Timecop.freeze do
      it 'remove the old poster and stores the film poster' do
        expect(film).to receive(:update_attributes).with(poster: 'RETURN_URL')
        expect(ImageUploader).to receive(:new)
          .with(width: 400,
                height: 600,
                url: 'poster_url.jpg',
                file_name: "posters/#{film.name.to_url}-#{film.year}/400x600-#{Time.now.strftime('%Y%m%d%H%M%S')}")
          .and_return(uploader)

        job
      end
    end
  end
end
