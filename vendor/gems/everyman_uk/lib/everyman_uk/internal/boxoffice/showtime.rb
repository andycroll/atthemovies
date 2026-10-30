# frozen_string_literal: true

module EverymanUk
  # @api private
  module Internal
    module Boxoffice
      # Reads one Boxoffice showtime: its start, booking link and tags
      class Showtime
        # Boxoffice tags and the variants they mean. Chains label them
        # differently, e.g. KidsFriendly is Everyman's Toddler Club.
        VARIANTS = {
          "Format.Projection.35mm" => "35mm",
          "Showtime.Accessibility.AutismFriendly" => "relaxed",
          "Showtime.Accessibility.ClosedCaption" => "subtitled",
          "Showtime.Accessibility.SensoryFriendly" => "relaxed",
          "Showtime.Accessibility.Subtitled" => "subtitled",
          "Showtime.Event.QandAEvent" => "q&a",
          "Showtime.Experience.EncoreShow" => "arts",
          "Showtime.Experience.FamilyFriendly" => "kids",
          "Showtime.Experience.LiveSatellite" => "arts",
          "Showtime.Experience.LiveShow" => "arts",
          "Showtime.Restriction.BabyClub" => "baby",
          "Showtime.Restriction.KidsFriendly" => "kids",
          "Showtime.Restriction.LoyaltyOnly" => "members",
          "Showtime.Restriction.SilverScreen" => "senior"
        }.freeze

        THREE_D = "Format.Projection.3d"
        LANGUAGE = /\ALocalization\.Language\.(\w+)\z/

        # @param [Hash] showtime one showtime from the schedule
        # @param [String] time_zone the theatre's, e.g. 'Europe/London'
        def initialize(showtime, time_zone:)
          @showtime = showtime
          @time_zone = time_zone
        end

        # @return [String, nil] the chain's own booking page
        def booking_url
          ticketing = @showtime.dig("data", "ticketing") || []
          link = ticketing.find { |entry| entry["provider"] == "default" } || ticketing.first
          link&.fetch("urls", [])&.first
        end

        # @return [String] '2d' or '3d'
        def dimension
          tags.any? { |tag| tag.casecmp?(THREE_D) } ? "3d" : "2d"
        end

        # @return [String, nil] audio language, e.g. 'Korean'
        def language
          tags.filter_map { |tag| tag[LANGUAGE, 1] }.first
        end

        # startsAt is the theatre's local time, without an offset
        # @return [Time] UTC
        def starting_at
          local = Time.utc(*@showtime.fetch("startsAt").scan(/\d+/).map(&:to_i))
          TZInfo::Timezone.get(@time_zone).local_to_utc(local) { |periods| periods.first }.utc
        end

        # @return [Array<String>]
        def variant
          tags.filter_map { |tag| VARIANTS[tag] }.uniq
        end

        private

        def tags
          @showtime.fetch("tags", [])
        end
      end
    end
  end
end
