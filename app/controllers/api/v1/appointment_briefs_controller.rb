# app/controllers/api/v1/appointment_briefs_controller.rb

module Api
  module V1
    class AppointmentBriefsController < BaseController
      before_action :set_appointment_brief, only: [:show, :destroy, :regenerate]

      def index
        appointment_briefs = current_user.appointment_briefs.order(created_at: :desc)

        render json: {
          appointment_briefs: appointment_briefs.map { |brief| appointment_brief_json(brief) }
        }
      end

      def show
        render json: {
          appointment_brief: appointment_brief_json(@appointment_brief)
        }
      end

      def create
        topic = params[:topic].to_s.strip

        if topic.blank?
          render json: { error: "Topic cannot be empty." }, status: :unprocessable_entity
          return
        end

        brief = HealthCopilot::GenerateAppointmentBriefService.new(
          user: current_user,
          topic: topic
        ).call

        if brief.nil?
          render json: { error: "Could not create appointment brief." }, status: :unprocessable_entity
          return
        end

        render json: {
          appointment_brief: appointment_brief_json(brief)
        }, status: :created
      rescue => e
        Rails.logger.error "Appointment brief API create error: #{e.message}"
        render json: { error: "Could not create appointment brief: #{e.message}" }, status: :internal_server_error
      end

      def regenerate
        if @appointment_brief.topic.blank?
          render json: {
            error: "This brief cannot be regenerated because it does not have a saved topic."
          }, status: :unprocessable_entity
          return
        end

        brief = HealthCopilot::RegenerateAppointmentBriefService.new(
          appointment_brief: @appointment_brief
        ).call

        render json: {
          appointment_brief: appointment_brief_json(brief)
        }
      rescue => e
        Rails.logger.error "Appointment brief API regenerate error: #{e.message}"
        render json: { error: "Could not regenerate appointment brief: #{e.message}" }, status: :internal_server_error
      end

      def destroy
        @appointment_brief.destroy

        render json: {
          message: "Appointment brief deleted."
        }
      end

      private

      def set_appointment_brief
        @appointment_brief = current_user.appointment_briefs.find(params[:id])
      end

      def appointment_brief_json(brief)
        {
          id: brief.id,
          topic: brief.topic,
          title: brief.title,
          content: brief.content,
          created_at: brief.created_at,
          updated_at: brief.updated_at
        }
      end
    end
  end
end
