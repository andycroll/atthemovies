# frozen_string_literal: true
class CinemaSerializer < ActiveModel::Serializer
  attributes :brand, :country, :country_code, :extended_address, :id, :latitude,
             :locality, :longitude, :postal_code, :name, :street_address, :url
end
