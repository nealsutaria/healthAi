module Clinic
  class InvitationAcceptancesController < ApplicationController
    before_action :set_clinic_invitation

    def show
      if @clinic_invitation.accepted?
        redirect_to clinic_organizations_path,
                    alert: "This invitation has already been accepted."
        return
      end

      unless user_signed_in?
        redirect_to new_user_session_path,
                    alert: "Please log in or sign up with #{@clinic_invitation.email} first, then open the invitation link again."
        return
      end
    end

    def create
      unless user_signed_in?
        redirect_to new_user_session_path,
                    alert: "Please log in or sign up with #{@clinic_invitation.email} first, then open the invitation link again."
        return
      end

      if @clinic_invitation.accepted?
        redirect_to clinic_organizations_path,
                    alert: "This invitation has already been accepted."
        return
      end

      unless current_user.email.downcase == @clinic_invitation.email.downcase
        redirect_to clinic_invitation_acceptance_path(@clinic_invitation.token),
                    alert: "This invitation was sent to #{@clinic_invitation.email}. Please log in with that email to accept it."
        return
      end

      ActiveRecord::Base.transaction do
        Membership.find_or_create_by!(
          user: current_user,
          organization: @clinic_invitation.organization
        ) do |membership|
          membership.role = @clinic_invitation.role
        end

        @clinic_invitation.update!(accepted_at: Time.current)
      end

      redirect_to clinic_organization_path(@clinic_invitation.organization),
                  notice: "You joined #{@clinic_invitation.organization.name}."
    end

    private

    def set_clinic_invitation
      @clinic_invitation = ClinicInvitation.find_by!(token: params[:token])
    end
  end
end
