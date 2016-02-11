require 'rails_helper'

describe Performances::Import do
  let(:job) { described_class.new.perform(attributes) }
  let!(:cinema) { create(:cinema) }

  describe '#perform' do
    let(:attributes) do
      {
        cinema_id:  cinema.id,
        film_name:  'Iron Man 3',
        starting_at: 100.hours.from_now,
        dimension:  '2d',
        variant:    ''
      }
    end

    context 'film and performance do not exist' do
      it 'creates a new performance' do
        expect { job }.to change(Performance, :count).from(0).to(1)

        performance = Performance.last
        expect(performance.film).to eq(Film.last)
        expect(performance.cinema).to eq(cinema)
        expect(performance.starting_at).to be_eq_to_time(attributes[:starting_at])
        expect(performance.dimension).to eq(attributes[:dimension])
        expect(performance.variant).to eq(attributes[:variant])
      end

      it 'creates a new film' do
        expect { job }.to change(Film, :count).from(0).to(1)

        film = Film.last
        expect(film.name).to eq(attributes[:film_name])
      end
    end

    context 'film exists with name' do
      let!(:film) { create(:film, name: attributes[:film_name]) }

      context 'performance does not exist' do
        it 'creates a new performance' do
          expect { job }.to change(Performance, :count).from(0).to(1)

          performance = Performance.last
          expect(performance.film).to eq(film)
          expect(performance.cinema).to eq(cinema)
          expect(performance.starting_at).to be_eq_to_time(attributes[:starting_at])
          expect(performance.dimension).to eq(attributes[:dimension])
          expect(performance.variant).to eq(attributes[:variant])
        end

        it 'does not create a new film' do
          expect { job }.not_to change(Film, :count)
        end
      end

      context 'performance exists at time' do
        let!(:performance) do
          create(
            :performance,
            cinema:     cinema,
            film:       film,
            dimension:  attributes[:dimension],
            starting_at: attributes[:starting_at],
            variant:    'baby',
            updated_at: 1.day.ago
          )
        end

        it 'does not create a new performance' do
          expect { job }.not_to change(Performance, :count)
        end

        it 'updates timestamp' do
          original = performance.updated_at
          job
          expect(performance.reload.updated_at).not_to be_eq_to_time(original)
        end

        it 'sets variant' do
          job
          expect(performance.reload.variant).to eq(attributes[:variant])
        end
      end
    end

    context 'film exists with alternate name' do
      let!(:film) { create(:film, alternate_names: [attributes[:film_name]]) }

      context 'performance does not exist' do
        it 'creates a new performance' do
          expect { job }.to change(Performance, :count).from(0).to(1)

          performance = Performance.last
          expect(performance.film).to eq(film)
          expect(performance.cinema).to eq(cinema)
          expect(performance.starting_at).to be_eq_to_time(attributes[:starting_at])
          expect(performance.dimension).to eq(attributes[:dimension])
          expect(performance.variant).to eq(attributes[:variant])
        end

        it 'does not create a new film' do
          expect { job }.not_to change(Film, :count)
        end
      end
    end
  end
end
