# frozen_string_literal: true

#-- copyright
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
#++

module Projects
  class ReuploadCreationWizardArtifactService < ::BaseServices::BaseCallable
    include Contracted
    include ProjectHelper
    include Rails.application.routes.url_helpers

    attr_reader :current_user, :work_package
    delegate :project, to: :work_package

    def initialize(current_user:, work_package:)
      super()

      @current_user = current_user
      @work_package = work_package
    end

    def call
      User.execute_as_admin(current_user) do
        update_artifact
      end
    end

    private

    def update_artifact
      if store_attachment_locally?
        add_attachment_locally
      end

      if project_storage.nil?
        return ServiceResult.failure(message: I18n.t("projects.wizard.create_artifact_storage_error"))
      end

      upload_artifact_to_storage(service_call)
    end

    def store_attachment_locally?
      project.project_creation_wizard_artifact_export_type == "attachment"
    end

    def upload_artifact_to_storage
      export = create_pdf_export!

      Storages::UploadFileService
        .call(
          container: work_package,
          project_storage:,
          file_path: project.project_creation_wizard_artifact_name,
          file_data: StringIO.new(export.content),
          filename: export.title
        )
    end

    def project_storage
      return @project_storage if defined?(@project_storage)

      @project_storage = project
        .project_storages
        .find_by(id: project.project_creation_wizard_artifact_export_storage)
    end

    def add_attachment_locally
      export = create_pdf_export!
      file = OpenProject::Files.create_uploaded_file(
        name: export.title,
        content_type: export.mime_type,
        content: export.content,
        binary: true
      )

      result = work_package.attachments.create(
        author: current_user,
        file:
      )

      ServiceResult.new(result:, errors: work_package.errors)
    end

    def create_pdf_export!
      Project::PDFExport::ProjectInitiation.new(project).export!
    end

    def pdf_attachment
      export = create_pdf_export!
      file = OpenProject::Files.create_uploaded_file(
        name: export.title,
        content_type: export.mime_type,
        content: export.content,
        binary: true
      )

      Attachment.new(
        container: nil,
        author: current_user,
        file:
      )
    end
  end
end
