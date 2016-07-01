class PerformanceSerializer < ActiveModel::Serializer
  class IdSerializer < ActiveModel::Serializer
    attributes :id
  end

  attributes :id, :dimension, :starting_at, :variant

  belongs_to :cinema, serializer: IdSerializer
  belongs_to :film, serializer: IdSerializer
end
