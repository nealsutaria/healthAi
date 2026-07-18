class ClinicInvitationMailer < ApplicationMailer
  def invite
    @clinic_invitation = params[:clinic_invitation]
    @organization = @clinic_invitation.organization
    @invited_by = @clinic_invitation.invited_by

    @accept_url = clinic_invitation_acceptance_url(@clinic_invitation.token)

    mail(
      to: @clinic_invitation.email,
      subject: "You're invited to join #{@organization.name} on MHBright"
    )
  end
end
