# frozen_string_literal: true
require 'spec_helper'
require_relative '../../app/services/film_name_comparison'

describe FilmNameComparison do
  describe '#code' do
    subject(:code) { described_class.new(name).code }

    [nil, '', 'abc', 'SGD 3', 'fdjk m  sak', 'don: tie', 'some,'].each do |word|
      context "name is '#{word}'" do
        let(:name) { word }

        it 'includes only lowercase alphabetical characters' do
          expect(code).to match(/\A[0-9]*[a-z]*\z/)
        end

        it 'sorts all characters into alphabetical order' do
          code.chars[0..-2].each_with_index do |char, i|
            expect(char).to be <= code[i + 1]
          end
        end
      end
    end
  end
end
