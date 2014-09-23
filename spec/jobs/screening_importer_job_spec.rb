require 'rails_helper'

describe ScreeningImporterJob do
  let(:job) { ScreeningImporterJob.new(attributes) }
  let!(:cinema) { create(:cinema) }

  describe '#perform' do
    let(:attributes) do
      {
        cinema_id:  cinema.id,
        film_name:  'Iron Man 3',
        showing_at: 100.hours.from_now,
        dimension:  '2d',
        variant:    ''
      }
    end

    context 'film and screening do not exist' do
      it 'creates a new screening' do
        expect { job.perform }.to change(Screening, :count).from(0).to(1)

        screening = Screening.last
        expect(screening.film).to eq(Film.last)
        expect(screening.cinema).to eq(cinema)
        expect(screening.showing_at).to eq(attributes[:showing_at])
        expect(screening.dimension).to eq(attributes[:dimension])
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
          expect(screening.dimension).to eq(attributes[:dimension])
          expect(screening.variant).to eq(attributes[:variant])
        end

        it 'does not create a new film' do
          expect { job.perform }.not_to change(Film, :count)
        end
      end

      context 'screening exists at time' do
        let!(:screening) do
          create(
            :screening,
            cinema:     cinema,
            film:       film,
            dimension:  attributes[:dimension],
            showing_at: attributes[:showing_at],
            updated_at: 2.days.ago
          )
        end

        it 'does not create a new screening' do
          expect { job.perform }.not_to change(Screening, :count)
        end

        it 'updates timestamp' do
          original = screening.updated_at
          Timecop.freeze(1.day.from_now) { job.perform }
          expect(screening.reload.updated_at).not_to eq(original)
        end

        it 'sets variant' do
          job.perform
          expect(screening.reload.variant).to eq(attributes[:variant])
        end
      end
    end
  end
end
