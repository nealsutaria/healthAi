module Clinic
  class ClinicInvitationsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_organization
    before_action :require_owner!

    def new
      @clinic_invitation = @organization.clinic_invitations.new
    end

    def create
      @clinic_invitation = @organization.clinic_invitations.new(clinic_invitation_params)
      @clinic_invitation.invited_by = current_user

      if @clinic_invitation.save
        redirect_to clinic_organization_memberships_path(@organization),
                    notice: "Invitation created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      clinic_invitation = @organization.clinic_invitations.find(params[:id])
      clinic_invitation.destroy

      redirect_to clinic_organization_memberships_path(@organization),
                  notice: "Invitation deleted."
    end

    private

    def set_organization
      @organization = current_user.organizations.find(params[:organization_id])
    end

    def require_owner!
      membership = current_user.memberships.find_by(organization: @organization)

      unless membership&.can_manage_members?
        redirect_to clinic_organization_path(@organization),
                    alert: "Only clinic owners can manage invitations."
      end
    end

    def clinic_invitation_params
      params.require(:clinic_invitation).permit(:email, :role)
    end
  end
end
