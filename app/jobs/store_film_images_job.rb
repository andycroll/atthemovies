require "stringio"

class StoreFilmImagesJob < ApplicationJob
  def perform(film)
    %w[poster backdrop].each do |kind|
      url = film.public_send("#{kind}_source_url")
      next if url.blank? || film.public_send(kind).blob&.metadata&.fetch("source_url", nil) == url
      raise ArgumentError, "Invalid image source" unless film.valid?
      data = HttpClient.new.request(url)
      film.with_lock do
        next unless film.public_send("#{kind}_source_url") == url
        next if film.public_send(kind).blob&.metadata&.fetch("source_url", nil) == url
        film.public_send(kind).attach(io: StringIO.new(data), filename: File.basename(URI(url).path), content_type: url.end_with?("png") ? "image/png" : "image/jpeg", metadata: { source_url: url })
      end
    end
  end
end
