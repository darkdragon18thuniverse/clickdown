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
    class EnabledEventsForm < ApplicationForm
      delegate :event_names, to: :model

      form do |f|
        # Primer, unlike Rails' check_box helper, does not render this auxilary hidden field for us.
        f.hidden name: "webhook[events][]", value: "", scope_name_to_model: false

        f.check_box_group(
          name: :events,
          label: I18n.t(:"webhooks.outgoing.form.events.title"),
          data: { controller: "checkable" },
          id: "enabled_events_fieldset"
        ) do |group|
          available_events.each do |label, value|
            group.check_box(
              label:,
              value:,
              checked: event_names.include?(value),
              data: { checkable_target: "checkbox" }
            )
          end
        end
      end

      private

      def available_events
        OpenProject::Webhooks::EventResources
          .available_events_map
          .flat_map do |resource_label, events|
          events.map do |key, label|
            ["#{resource_label}: #{label}", key]
          end
        end
      end
    end
  end
end
