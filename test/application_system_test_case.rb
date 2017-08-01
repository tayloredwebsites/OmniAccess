require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # on mac install chrome driver by: $ brew install chromedriver
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
end
