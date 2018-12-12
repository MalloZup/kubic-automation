require "spec_helper"
require "uri"
require "yaml"
require "openssl"
require "net/http"

feature "Add Remote Registry" do
  before do
    login unless inspect.include? "User registers"
  end

  # Using append after in place of after, as recommended by
  # https://github.com/mattheworiordan/capybara-screenshot#common-problems
  append_after do
    Capybara.reset_sessions!
  end

  # User registration and cluster configuration has already been done in 01-setup-velum.rb
  # After login we simply press Next to reach the minion discovery page
  scenario "User adds a remote registry" do
    with_screenshot(name: :remote_registries_page) do
      with_status_ok do
        visit "/settings/registries"
      end
    end

    puts ">>> User clicks to add remote registry"
    with_screenshot(name: :add_remote_registry) do
      click_on "Add Remote Registry"
    end
    puts "<<< User clicks to add remote registry"

    # Get the remote registry name and URL from environment variables, or use defaults that won't
    # actually work in real life
    remote_registry_name = ENV.fetch("REMOTE_REGISTRY_NAME", 'test-remote-registry')
    remote_registry_url = ENV.fetch("REMOTE_REGISTRY_URL", 'https://test-remote-registry.com')
    puts ">>> Adding remote registry " + remote_registry_name + " - " + remote_registry_url + " <<<"

    puts ">>> User adds new remote registry"
    expect(page).to have_text("New Remote Registry")
    with_screenshot(name: :new_remote_registry) do
      fill_in "Name", with: remote_registry_name
      fill_in "URL", with: remote_registry_url
      click_button "Save"
    end
    puts "<<< User adds new remote registry"

    puts ">>> User clicks to apply changes"
    with_screenshot(name: :apply_remote_registry_changes) do
      expect(page).to have_text(remote_registry_name + " registry details")
      expect(page).to have_text(remote_registry_url)
      click_button "Apply changes"
    end
    puts "<<< User clicks to apply changes"

    # Add remote registry information to the environment file
    env = environment(action: :read)
    registries = env.fetch("remoteRegistries", [])
    env["remoteRegistries"] = registries << {"name" => remote_registry_name,
                                             "url" => remote_registry_url}
    environment(action: :update, body: env)
  end
end
