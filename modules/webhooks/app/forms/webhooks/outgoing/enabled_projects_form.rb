# frozen_string_literal: true

# -- copyright
# OpenProject is an open source project management software.
# Copyright (C) the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
# ++
#

module Webhooks
  module Outgoing
    class EnabledProjectsForm < ApplicationForm
      class SelectedProjectsForm < ApplicationForm
        alias :webhook :model

        form do |f|
          f.select_panel(
            name: :selected_project_ids,
            label: I18n.t(:"webhooks.outgoing.form.selected_project_ids.title"),
            title: I18n.t("types.edit.projects.select_projects"),
            visually_hide_label: true,
            disabled: webhook.all_projects?,
            select_variant: :multiple,
            dynamic_label: true,
            dynamic_label_prefix: I18n.t(:"webhooks.outgoing.form.selected_project_ids.title"),
            src: url_helpers.enabled_projects_menu_admin_outgoing_webhooks_path(
              select_variant: :multiple,
              selected_project_ids: webhook.all_projects? ? [] : webhook.project_ids
            ),
            fetch_strategy: :remote
          ) do |menu|
            # available_projects.each do |label, value|
            #   menu.with_item(
            #     label:,
            #     content_arguments: { data: { value: } },
            #     active: !webhook.all_projects? && webhook.project_ids.include?(value)
            #   )
            # end
          end

          # Primer, unlike Rails' check_box helper, does not render this auxilary hidden field for us.
          # f.hidden name: "webhook[selected_project_ids][]", value: "", scope_name_to_model: false
          #
          # f.check_box_group(
          #   name: :selected_project_ids,
          #   label: I18n.t(:"webhooks.outgoing.form.selected_project_ids.title"),
          #   visually_hide_label: true,
          #   disabled: webhook.all_projects?,
          #   data: {
          #     disable_when_value_selected_target: "effect",
          #     value: "selection"
          #   }
          # ) do |group|
          #   available_projects.each do |label, value|
          #     group.check_box(
          #       label:,
          #       value:,
          #       checked: !webhook.all_projects? && webhook.project_ids.include?(value)
          #     )
          #   end
        end

        private

        def available_projects
          ::Project.pluck(:name, :id)
        end
      end
      alias :webhook :model

      form do |f|
        f.radio_button_group(
          name: :project_ids,
          label: I18n.t(:"webhooks.outgoing.form.project_ids.title"),
          caption: I18n.t(:"webhooks.outgoing.form.project_ids.description"),
          data: {
            controller: "disable-when-value-selected"
          }
        ) do |group|
          group.radio_button(
            value: "all",
            label: I18n.t(:"webhooks.outgoing.form.project_ids.all"),
            checked: webhook.all_projects?,
            data: {
              disable_when_value_selected_target: "cause"
            }
          )

          group.radio_button(
            value: "selection",
            label: I18n.t(:"webhooks.outgoing.form.project_ids.selected"),
            checked: !webhook.all_projects?,
            data: {
              disable_when_value_selected_target: "cause"
            }
          ) do |selection_radio_button|
            selection_radio_button.nested_form do |builder|
              SelectedProjectsForm.new(builder)
            end
          end
        end
      end
    end
  end
end
