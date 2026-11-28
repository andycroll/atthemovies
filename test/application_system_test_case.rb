require "test_helper"

# Capybara 3.40.0 clears storage on reset with origin "*", which Chrome 158
# rejects. Clear cookies and the app server's origin instead. Remove once
# Capybara ships a fix.
if Capybara::VERSION == "3.40.0"
  Capybara::Selenium::Driver::ChromeDriver.prepend(Module.new do
    private

    def execute_cdp(cmd, params = {})
      return super unless cmd == "Storage.clearDataForOrigin" && params[:origin] == "*"

      types = params[:storageTypes].to_s.split(",")
      super("Network.clearBrowserCookies") if types.delete("cookies")
      origin = Capybara.current_session.server&.base_url
      super(cmd, params.merge(origin: origin, storageTypes: types.join(","))) if origin && types.any?
    end
  end)
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ] do |options|
    options.binary = ENV["CHROME_BIN"] if ENV["CHROME_BIN"].present?
    options.add_argument("no-sandbox") if ENV["AMP_ORB"].present?
    options.add_argument("force-device-scale-factor=2")
    options.add_preference("profile.password_manager_leak_detection", false)
  end
end
