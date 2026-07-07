module Clinic
  class OrganizationsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_organization, only: [:show]

    def index
      @organizations = current_user.organizations.order(created_at: :desc)
    end

    def new
      @organization = Organization.new
    end

    def create
      @organization = Organization.new(organization_params)

      ActiveRecord::Base.transaction do
        @organization.save!

        Membership.create!(
          user: current_user,
          organization: @organization,
          role: "owner"
        )
      end

      redirect_to clinic_organization_path(@organization), notice: "Clinic created."
    rescue ActiveRecord::RecordInvalid
      render :new, status: :unprocessable_entity
    end

    def show
      @prior_auth_drafts = @organization.prior_auth_drafts.order(created_at: :desc).limit(3)
      @prior_auth_drafts_count = @organization.prior_auth_drafts.count
    end

    private

    def set_organization
      @organization = current_user.organizations.find(params[:id])
    end

    def organization_params
      params.require(:organization).permit(:name)
    end
  end
end
