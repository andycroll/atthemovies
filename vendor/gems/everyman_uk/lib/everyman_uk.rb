require 'json'

require 'cinebase'

require_relative './everyman_uk/version'

require_relative './everyman_uk/internal/http'
require_relative './everyman_uk/internal/boxoffice/client'
require_relative './everyman_uk/internal/boxoffice/showtime'
require_relative './everyman_uk/internal/api_response'
require_relative './everyman_uk/internal/title_sanitizer'

require_relative './everyman_uk/cinema'
require_relative './everyman_uk/performance'

# everyman_uk gem
module EverymanUk
end
