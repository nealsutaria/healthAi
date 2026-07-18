module Api
  module V1
    class RecordsController < BaseController
      def index
        records = current_user.records.order(date: :desc)

        render json: records.map { |record| record_json(record, include_analysis: false) }, status: :ok
      end

      def show
        record = current_user.records.find(params[:id])

        render json: record_json(record, include_analysis: true), status: :ok
      end

      def create
        record = current_user.records.new(record_params)

        if record.save
          render json: record_json(record, include_analysis: true), status: :created
        else
          render json: { errors: record.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        record = current_user.records.find(params[:id])

        if record.update(record_params)
          render json: record_json(record, include_analysis: true), status: :ok
        else
          render json: { errors: record.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        record = current_user.records.find(params[:id])
        record.destroy

        render json: { message: "Record deleted" }, status: :ok
      end

      def analyze_image
        record = current_user.records.find(params[:id])

        result = HealthCopilot::AnalyzeRecordImageService.new(record).call

        if result[:success]
          render json: record_json(record.reload, include_analysis: true), status: :ok
        else
          render json: { error: result[:error] }, status: :unprocessable_entity
        end
      end

      private

      def record_params
        params.require(:record).permit(
          :date,
          :reason,
          :prescription,
          :prescription_name,
          :xray_done,
          :test_done,
          :test_type,
          :doctor_rating,
          :comments,
          :image
        )
      end

      def record_json(record, include_analysis:)
        data = {
          id: record.id,
          date: record.date,
          reason: record.reason,
          prescription: record.prescription,
          prescription_name: record.prescription_name,
          xray_done: record.xray_done,
          test_done: record.test_done,
          test_type: record.test_type,
          doctor_rating: record.doctor_rating,
          comments: record.comments,
          image_url: image_url_for(record),
          created_at: record.created_at,
          updated_at: record.updated_at
        }

        data[:analysis] = record.analysis if include_analysis

        data
      end

      def image_url_for(record)
        return nil unless record.image.attached?

        Rails.application.routes.url_helpers.rails_blob_url(
          record.image,
          host: request.base_url
        )
      end
    end
  end
end
