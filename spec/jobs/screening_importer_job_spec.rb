require 'rails_helper'

describe ScreeningImporterJob do
  let(:job) { ScreeningImporterJob.new(attributes) }
  let!(:cinema) { create(:cinema) }

  describe '#perform' do
    let(:attributes) {
      {
        cinema_id:  cinema.id,
        film_name:  'Iron Man 3',
        showing_at: Time.utc(2014, 10, 1, 19, 0),
        variant:    '2D'
      }
    }

    context 'film and screening do not exist' do
      it 'creates a new screening' do
        expect { job.perform }.to change(Screening, :count).from(0).to(1)

        screening = Screening.last
        expect(screening.film).to eq(Film.last)
        expect(screening.cinema).to eq(cinema)
        expect(screening.showing_at).to eq(attributes[:showing_at])
        expect(screening.variant).to eq(attributes[:variant])
      end

      it 'creates a new film' do
        expect { job.perform }.to change(Film, :count).from(0).to(1)

        film = Film.last
        expect(film.name).to eq(attributes[:film_name])
      end
    end

    context 'film exists' do
      let!(:film) { create(:film, name: attributes[:film_name]) }

      context 'screening does not exist' do
        it 'creates a new screening' do
          expect { job.perform }.to change(Screening, :count).from(0).to(1)

          screening = Screening.last
          expect(screening.film).to eq(film)
          expect(screening.cinema).to eq(cinema)
          expect(screening.showing_at).to eq(attributes[:showing_at])
          expect(screening.variant).to eq(attributes[:variant])
        end

        it 'does not create a new film' do
          expect { job.perform }.not_to change(Film, :count)
        end
      end

      context 'screening exists at time' do
        let!(:screening) { create(:screening, cinema: cinema, film: film, showing_at: attributes[:showing_at]) }

        it 'does not create a new screening' do
          expect { job.perform }.not_to change(Screening, :count)
        end

        it 'updates timestamps' do
          Timecop.freeze(1.day.from_now) do
            expect(screening.updated_at).not_to eq(Time.current)
            job.perform
            expect(screening.reload.updated_at).to eq(Time.current)
          end
        end

        it 'sets variant' do
          job.perform
          expect(screening.reload.variant).to eq(attributes[:variant])
        end
      end
    end
  end
end
