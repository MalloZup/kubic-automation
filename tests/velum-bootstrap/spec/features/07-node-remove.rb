require "spec_helper"
require "yaml"

feature "Remove a Node" do
  let(:node_number_removable) do
    removable = node_number
    removable -= master_node_number unless node_removable?(role: "master")
    removable -= worker_node_number unless node_removable?(role: "worker")
    removable
  end

  before do
    login
  end

  # Using append after in place of after, as recommended by
  # https://github.com/mattheworiordan/capybara-screenshot#common-problems
  append_after do
    Capybara.reset_sessions!
  end

  scenario "User removes a node" do
    with_status_ok do
      visit "/"
    end

    puts ">>> Checking if node can be removed"
    with_screenshot(name: :node_removable) do
      within(".nodes-container") do
        expect(page).to have_link(text: "Remove", count: node_number_removable, wait: 120)
      end
    end
    puts "<<< A node can be removed"

    puts ">>> Click to remove a node"
    with_screenshot(name: :node_removal) do
      # mark node as inactive in environment.json
      node_to_remove = find(".remove-node-link", match: :first)
      environment(
        action: :update,
        body:   set_minion_status(node_to_remove.first(:xpath, ".//..")["data-id"], "removed")
      )
      node_to_remove.click
    end

    if page.has_content?("Unsupported cluster topology", wait: 5)
      with_screenshot(name: :unsupported_topology_modal) do
        click_button "Proceed anyway"
      end
    end

    puts ">>> Waiting for pending node removal"
    with_screenshot(name: :pending_node_removal) do
      within(".nodes-container") do
        expect(page).to have_text("Pending removal", count: 1, wait: 120)
      end
    end
    puts "<<< node removal pending"

    orchestration_timeout = [[3600, 120].max, 7200].min
    puts ">>> Waiting for node removal to be done"
    with_screenshot(name: :wait_node_removal) do
      within(".nodes-container") do
        expect(page).not_to have_text("Pending removal", wait: orchestration_timeout)
      end
    end
    puts "<<< node removal done"

    puts ">>> Checking if node removal orchestration succeeded"
    with_screenshot(name: :node_removal_orchestration_succeeded) do
      within(".nodes-container") do
        expect(page).to have_css(".fa-check-circle-o", count: node_number, wait: 5)
      end
      expect(page).not_to have_text("Removal Failed", wait: 5)
    end
    puts "<<< Node removal orchestration succeeded"
  end
end
