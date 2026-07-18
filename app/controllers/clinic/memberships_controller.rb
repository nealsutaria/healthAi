module Clinic
  class MembershipsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_organization
    before_action :require_owner!

    def index
      @memberships = @organization.memberships.includes(:user).order(created_at: :asc)
      @clinic_invitations = @organization.clinic_invitations.order(created_at: :desc)
    end

    def destroy
      membership = @organization.memberships.find(params[:id])

      if membership.user == current_user
        redirect_to clinic_organization_memberships_path(@organization),
                    alert: "You cannot remove yourself from the clinic."
        return
      end

      membership.destroy

      redirect_to clinic_organization_memberships_path(@organization),
                  notice: "Member removed."
    end

    private

    def set_organization
      @organization = current_user.organizations.find(params[:organization_id])
    end

    def require_owner!
      membership = current_user.memberships.find_by(organization: @organization)

      unless membership&.can_manage_members?
        redirect_to clinic_organization_path(@organization),
                    alert: "Only clinic owners can manage members."
      end
    end
  end
end
