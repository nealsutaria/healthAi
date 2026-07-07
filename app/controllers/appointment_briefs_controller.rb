class AppointmentBriefsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_appointment_brief, only: [:show, :destroy, :regenerate]

  def index
    @appointment_briefs = current_user.appointment_briefs.order(created_at: :desc)
  end

  def create
    topic = params[:topic].to_s.strip

    if topic.blank?
      redirect_to copilot_path, alert: "Please enter an appointment topic."
      return
    end

    brief = HealthCopilot::GenerateAppointmentBriefService.new(
      user: current_user,
      topic: topic
    ).call

    redirect_to appointment_brief_path(brief), notice: "Appointment brief created."
  end

  def show
  end

  def set_appointment_brief
    @appointment_brief = current_user.appointment_briefs.find(params[:id])
  end

  def regenerate
    if @appointment_brief.topic.blank?
      redirect_to @appointment_brief, alert: "This brief cannot be regenerated because it does not have a saved topic."
      return
    end

    response = HealthCopilot::RegenerateAppointmentBriefService.new(
      appointment_brief: @appointment_brief
    ).call

    redirect_to appointment_brief_path(response), notice: "Appointment brief regenerated."
  end

  def destroy
    @appointment_brief.destroy
    redirect_to appointment_briefs_path, notice: "Appointment brief deleted."
  end

  private

end
