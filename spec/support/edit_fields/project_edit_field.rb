# frozen_string_literal: true

require_relative "select_edit_field"

class ProjectEditField < SelectField
  def autocompleter
    if @selector&.start_with?("op")
      # Direct autocompleter selector (for settings pages)
      field_container
    else
      # Inline edit container (for work package tables)
      field_container.find("op-project-autocompleter")
    end
  end

  def search_for(query)
    search_autocomplete(autocompleter,
                        query:,
                        results_selector: ".ng-dropdown-panel-items")
  end

  def dropdown
    ng_find_dropdown(autocompleter, results_selector: ".ng-dropdown-panel-items")
  end

  def expect_option(name, workspace_badge: false)
    within(dropdown) do
      # Find the option containing the name
      option = page.find(".ng-option", text: name)

      if workspace_badge
        expect(option).to have_css("svg.octicon")
        expect(option).to have_css(".color-fg-muted", text: workspace_badge)
      else
        # Expect no octicon SVG
        expect(option).to have_no_css("svg.octicon")
        expect(option).to have_no_css(".color-fg-muted")
      end
    end
  end

  def clear_search
    ng_select_input(autocompleter).set("")
  end
end
