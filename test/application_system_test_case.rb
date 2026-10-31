require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, Integer(ENV.fetch("WIN_H", 1400)) ] do |options|
    options.binary = ENV["CHROME_BIN"] if ENV["CHROME_BIN"].present?
    options.add_argument("no-sandbox") if ENV["AMP_ORB"].present?
    options.add_argument("force-device-scale-factor=#{ENV.fetch("DPR", 2)}"); ENV["CHROME_ARGS"].to_s.split.each { |a| options.add_argument(a) }
  end
end
require ENV["INSTRUMENT"] if ENV["INSTRUMENT"].present?
