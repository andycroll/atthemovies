class DestroyPastScreenings
  def perform
    Screening.past.destroy_all
  end
end
