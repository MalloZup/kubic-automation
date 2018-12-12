# A module containing helper methods to create a testing environment
# for end to end tests.
module Helpers
  def with_screenshot(name:)
    save_screenshot("screenshots/#{Time.now.to_i}_before_#{name}.png", full: true)
    yield
    save_screenshot("screenshots/#{Time.now.to_i}_after_#{name}.png", full: true)
  end

  def with_status_ok
    yield
    expect(page.status_code).to eq(200)
  end

  private

  def login
    puts ">>> User logs in"
    with_status_ok do
      visit "/users/sign_in"
    end

    fill_in "user_email", with: "test@test.com"
    fill_in "user_password", with: "password"
    click_on "Log in"
    puts "<<< User logged in"
  end

  def default_interface
    `awk '$2 == 00000000 { print $1 }' /proc/net/route`.strip
  end

  def default_ip_address
    `ip addr show #{default_interface} | awk '$1 == "inet" {print $2}' | cut -f1 -d/`.strip
  end

end

RSpec.configure { |config| config.include Helpers, type: :feature }
