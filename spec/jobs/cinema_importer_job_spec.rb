require 'rails_helper'

describe CinemaImporterJob do
  let(:job) { CinemaImporterJob.new(attributes) }

  describe '#perform' do
    context 'cineworld example' do
      let(:attributes) {
        {
          name: 'Cineworld Brighton', brand: 'Cineworld', brand_identifier: 3,
          address: {
            street_address: 'Kingswest',
            locality: 'Brighton',
            region: 'East Sussex',
            postal_code: 'BN1 2RE',
            country: 'United Kingdom'
          }
        }
      }

      context 'cinema exists' do
        before { create(:cinema, name: 'Cineworld Brighton', brand: 'Cineworld', brand_identifier: '3') }

        it 'does not create a new cinema' do
          expect { job.perform }.not_to change(Cinema, :count)
        end

        it 'updates with specified address' do
          job.perform

          cinema = Cinema.last
          expect(cinema.street_address).to eq('Kingswest')
          expect(cinema.locality).to eq('Brighton')
          expect(cinema.postal_code).to eq('BN1 2RE')
          expect(cinema.country).to eq('United Kingdom')
        end
      end
    end

    context 'odeon example' do
      let(:attributes) {
        {
          name: 'Odeon Brighton', brand: 'Odeon', brand_identifier: 'brand-id',
          address: {
            street_address: 'Kingswest',
            locality: 'Brighton',
            region: 'East Sussex',
            postal_code: 'BN1 2RE',
            country: 'United Kingdom'
          }
        }
      }

      context 'cinema does not exist' do
        it 'creates a new cinema with specified address' do
          expect { job.perform }.to change(Cinema, :count).from(0).to(1)

          cinema = Cinema.last
          expect(cinema.street_address).to eq('Kingswest')
          expect(cinema.locality).to eq('Brighton')
          expect(cinema.postal_code).to eq('BN1 2RE')
          expect(cinema.country).to eq('United Kingdom')
        end
      end

      context 'cinema exists' do
        before { create :cinema, name: 'Odeon Brighton', brand: 'Odeon', brand_identifier: 'brand-id' }

        it 'does not create a new cinema' do
          expect { job.perform }.not_to change(Cinema, :count)
        end

        it 'updates with specified address' do
          job.perform

          cinema = Cinema.last
          expect(cinema.street_address).to eq('Kingswest')
          expect(cinema.locality).to eq('Brighton')
          expect(cinema.postal_code).to eq('BN1 2RE')
          expect(cinema.country).to eq('United Kingdom')
        end
      end
    end

    context 'picturehouse example' do
      let(:attributes) do
        {
          name: 'Duke of Yorks', brand: 'Picturehouse', brand_identifier: 'doy',
          address: {
            street_address: 'The Street',
            locality: 'Brighton',
            region: 'East Sussex',
            postal_code: 'BN2 1HD',
            country: 'United Kingdom'
          }
        }
      end

      context 'cinema exists' do
        before do
          create(:cinema,
                 name: 'Duke of Yorks',
                 brand: 'Picturehouse',
                 brand_identifier: 'doy')
        end

        it 'does not create a new cinema' do
          expect { job.perform }.not_to change(Cinema, :count)
        end

        it 'updates with specified address' do
          job.perform

          cinema = Cinema.last
          expect(cinema.street_address).to eq('The Street')
          expect(cinema.locality).to eq('Brighton')
          expect(cinema.postal_code).to eq('BN2 1HD')
          expect(cinema.country).to eq('United Kingdom')
        end
      end
    end
  end
end
