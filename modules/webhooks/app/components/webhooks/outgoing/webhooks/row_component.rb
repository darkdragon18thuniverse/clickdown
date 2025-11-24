module ::Webhooks
  module Outgoing
    module Webhooks
      class RowComponent < ::RowComponent
        property :description

        def webhook
          model
        end

        def name
          link_to webhook.name,
                  { controller: table.target_controller, action: :show, webhook_id: webhook.id }
        end

        def enabled
          if webhook.enabled?
            helpers.op_icon "icon-yes"
          end
        end

        def events
          selected_events =
            webhook
              .events
              .pluck(:name)
              .map(&method(:lookup_event_name))
              .compact
              .uniq

          count = selected_events.size
          if count <= 3
            selected_events.join(", ")
          else
            content_tag("span", count, class: "badge")
          end
        end

        def lookup_event_name(name)
          OpenProject::Webhooks::EventResources.lookup_resource_name(name)
        end

        def selected_projects
          if webhook.all_projects?
            return "(#{I18n.t(:label_all)})"
          end

          count = webhook.projects.size
          case count
          when 0
            "(#{I18n.t(:label_all)})"
          when 1..3
            webhook.projects.pluck(:name).join(", ")
          else
            content_tag("span", count, class: "badge")
          end
        end

        def row_css_class
          [
            "webhooks--outgoing-webhook-row",
            "webhooks--outgoing-webhook-row-#{model.id}"
          ].join(" ")
        end

        ###

        def button_links
          [edit_link, delete_link]
        end

        def edit_link
          link_to(
            helpers.op_icon("icon icon-edit button--link"),
            { controller: table.target_controller, action: :edit, webhook_id: webhook.id },
            title: t(:button_edit)
          )
        end

        def delete_link
          link_to(
            helpers.op_icon("icon icon-delete button--link"),
            { controller: table.target_controller, action: :destroy, webhook_id: webhook.id },
            data: { turbo_method: :delete, turbo_confirm: I18n.t(:text_are_you_sure) },
            title: t(:button_delete)
          )
        end
      end
    end
  end
end
