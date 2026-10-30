module EverymanUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Sanitize and standardize film titles
    class TitleSanitizer < Cinebase::TitleSanitizer
      # @!method initialize(title)
      #   Constructor
      #   @param [String] title a film title
      #   @return [EverymanUk::Internal::TitleSanitizer]

      # @!method sanitized
      #   sanitized and standardized title
      #   @return [String] sanitised title

      private

      # strings and regex to be removed
      def remove
        [
          /\AMembers['’]? Preview:\s*/i, # members' screening ahead of release
          /\s+presented by [^:()]+\z/i   # partner's screening
        ] + COMMON_REMOVE
      end

      # regexes and their replacements
      def replace
        COMMON_REPLACE
      end
    end
  end
end
