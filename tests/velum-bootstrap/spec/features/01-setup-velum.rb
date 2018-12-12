require "spec_helper"
require "yaml"

feature "Register user and configure cluster" do
  before do
    login unless inspect.include? "User registers"
  end

  # Using append after in place of after, as recommended by
  # https://github.com/mattheworiordan/capybara-screenshot#common-problems
  append_after do
    Capybara.reset_sessions!
  end

  scenario "User registers" do
    with_screenshot(name: :register) do
      puts ">>> Registering user"
      with_status_ok do
        visit "/users/sign_up"
      end
      fill_in "user_email", with: "test@test.com"
      fill_in "user_password", with: "password"
      fill_in "user_password_confirmation", with: "password"
      click_on "Create Admin"
      puts "<<< User registered"
    end
  end

  scenario "User configures the cluster" do
    with_screenshot(name: :configure) do
      puts ">>> Setting up velum"

      with_status_ok do
        visit "/setup"
      end

      fill_in "settings_dashboard", with: environment["dashboardHost"] || default_ip_address

      # check Tiller checkbox
      enable_tiller = ENV.fetch("ENABLE_TILLER", "false") == "true"

      if enable_tiller == true
        puts ">>> Enabling Tiller"
        check "settings[tiller]"
      else
        puts ">>> Disabling Tiller"
        uncheck "settings[tiller]"
      end

      environment(
        action: :update,
        body:   set_feature("tiller", {"enabled" => enable_tiller})
      )

      # choose cri-o engine by pressing button
      cri_implementation = ENV.fetch("CHOOSE_CRIO", false) == "true" ? "crio" : "docker"

      if cri_implementation == "crio"
        # using the "chose" function fails with a MouseEventFailed overlap error
        page.find('#settings_container_runtime_crio').trigger(:click)
      else
        page.find('#settings_container_runtime_docker').trigger(:click)
      end

      environment(
        action: :update,
        body:   set_feature("cri", {"implementation" => cri_implementation})
      )

      click_on "Next"
      puts "<<< Velum set up"
    end
  end

  scenario "User proceeds past AutoYaST page" do
    with_screenshot(name: :skip_autoyast) do
      puts ">>> Skipping past the AutoYaST page"
      visit "/setup/worker-bootstrap"
      click_on "Next"
      puts "<<< Skipped past the AutoYaST page"
    end
  end
end
