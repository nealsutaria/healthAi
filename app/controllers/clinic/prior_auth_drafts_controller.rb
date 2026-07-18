module Clinic
  class PriorAuthDraftsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_organization
    before_action :set_prior_auth_draft, only: [:show, :edit, :update, :destroy]
    before_action :require_prior_auth_view_access!
    before_action :require_prior_auth_manage_access!, only: [:new, :create, :edit, :update, :destroy]

    def index
      @prior_auth_drafts = @organization.prior_auth_drafts.order(created_at: :desc)
    end

    def new
      @prior_auth_draft = @organization.prior_auth_drafts.new
    end

    def create
      @prior_auth_draft = @organization.prior_auth_drafts.new(prior_auth_draft_params)
      @prior_auth_draft.user = current_user
      @prior_auth_draft.status = "draft"
      @prior_auth_draft.content = "Generating prior authorization packet..."

      if @prior_auth_draft.save
        HealthCopilot::GeneratePriorAuthDraftService.new(
          prior_auth_draft: @prior_auth_draft
        ).call

        redirect_to clinic_organization_prior_auth_draft_path(@organization, @prior_auth_draft),
                    notice: "Prior authorization packet generated."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
    end

    def destroy
      @prior_auth_draft.destroy
      redirect_to clinic_organization_prior_auth_drafts_path(@organization),
                  notice: "Prior authorization draft deleted."
    end

    def edit
    end

    def update
      if @prior_auth_draft.update(prior_auth_draft_params)
        HealthCopilot::GeneratePriorAuthDraftService.new(
          prior_auth_draft: @prior_auth_draft
        ).call

        redirect_to clinic_organization_prior_auth_draft_path(@organization, @prior_auth_draft),
                    notice: "Prior authorization packet updated and regenerated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_organization
      @organization = current_user.organizations.find(params[:organization_id])
    end

    def set_prior_auth_draft
      @prior_auth_draft = @organization.prior_auth_drafts.find(params[:id])
    end

    def prior_auth_draft_params
      params.require(:prior_auth_draft).permit(
        :patient_name,
        :condition,
        :requested_service,
        :insurance_payer,
        :prior_treatments,
        :clinical_notes,
        :tests_or_imaging
      )
    end
    def current_membership
      @current_membership ||= current_user.memberships.find_by(organization: @organization)
    end

    def require_prior_auth_view_access!
      unless current_membership&.can_view_prior_auth_drafts?
        redirect_to clinic_organizations_path,
                    alert: "You do not have access to this clinic."
      end
    end

    def require_prior_auth_manage_access!
      unless current_membership&.can_manage_prior_auth_drafts?
        redirect_to clinic_organization_prior_auth_drafts_path(@organization),
                    alert: "You do not have permission to manage prior authorization drafts."
      end
    end
  end
end
