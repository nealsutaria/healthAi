module Clinic
  class PriorAuthDraftsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_organization
    before_action :set_prior_auth_draft, only: [:show, :edit, :update, :destroy]

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
  end
end
