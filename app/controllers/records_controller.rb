require "net/http"
require "json"
require "open-uri"
require "base64"
require "mini_magick"

class RecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_record, only: %i[show edit update destroy doctor_suggestion analyze_image]

  # GET /records
  def index
    @records = current_user.records.order(date: :desc)
  end

  # GET /records/1
  def show
    authorize_record!
  end

  # GET /records/new
  def new
    @record = current_user.records.new
  end

  # GET /records/1/edit
  def edit
    authorize_record!
  end

  # POST /records
  def create
    @record = current_user.records.new(record_params)

    respond_to do |format|
      if @record.save
        format.html { redirect_to @record, notice: "Record was successfully created." }
        format.json { render :show, status: :created, location: @record }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /records/1
  def update
    authorize_record!

    respond_to do |format|
      if @record.update(record_params)
        format.html { redirect_to @record, notice: "Record was successfully updated." }
        format.json { render :show, status: :ok, location: @record }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /records/1
  def destroy
    authorize_record!
    @record.destroy!

    respond_to do |format|
      format.html { redirect_to records_path, status: :see_other, notice: "Record was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # POST /records/:id/doctor_suggestion
  def doctor_suggestion
    authorize_record!

    prompt = <<~TEXT
      Health Record Summary:
      Date: #{@record.date}
      Reason for visit: #{@record.reason}
      Prescription: #{@record.prescription? ? "Yes – #{@record.prescription_name}" : "No"}
      X-ray done: #{@record.xray_done? ? "Yes" : "No"}
      Test done: #{@record.test_done? ? "Yes – #{@record.test_type}" : "No"}
      Doctor rating (out of 5): #{@record.doctor_rating}
      Comments from patient: #{@record.comments.presence || "None"}

      Based on this health record, does the patient need to follow up with a doctor soon?
      Be brief and clear. Give one helpful recommendation in plain language.
    TEXT

    suggestion = fetch_gemini_response(prompt)
    render json: { suggestion: suggestion }
  end

  # POST /records/:id/analyze_image
  def analyze_image
    authorize_record!

    unless @record.image.attached?
      redirect_to @record, alert: "No image attached to analyze."
      return
    end

    begin
      # Download image and resize
      downloaded_file = URI.open(@record.image.url)
      image = MiniMagick::Image.read(downloaded_file)
      image.resize "800x800>"
      base64_image = Base64.strict_encode64(image.to_blob)

      api_key = Rails.application.credentials.gemini_api_key
      uri = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=#{api_key}")

      body = {
        contents: [
          {
            parts: [
              { text: "Please analyze and explain this medical image clearly." },
              {
                inline_data: {
                  mime_type: "image/jpeg",
                  data: base64_image
                }
              }
            ]
          }
        ]
      }

      headers = { "Content-Type" => "application/json" }

      response = Net::HTTP.post(uri, body.to_json, headers)
      json = JSON.parse(response.body)

      result = json.dig("candidates", 0, "content", "parts", 0, "text")
      if result.present?
        @record.update(analysis: result)
        flash[:notice] = "Image analyzed successfully."
      else
        flash[:alert] = "Gemini could not analyze the image."
        Rails.logger.error "Gemini error: #{json.inspect}"
      end
    rescue => e
      Rails.logger.error "Gemini image analysis failed: #{e.message}"
      flash[:alert] = "Something went wrong while analyzing the image."
    end

    redirect_to @record
  end

  private

    def set_record
      @record = Record.find(params[:id])
    end

    def authorize_record!
      redirect_to records_path, alert: "Not authorized." unless @record.user == current_user
    end

    def record_params
      params.require(:record).permit(
        :date, :reason, :image, :prescription, :prescription_name,
        :xray_done, :test_done, :test_type, :doctor_rating, :comments
      )
    end

    def fetch_gemini_response(prompt)
      api_key = Rails.application.credentials.gemini_api_key
      uri = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=#{api_key}")
      headers = { "Content-Type" => "application/json" }
      body = {
        contents: [{ parts: [{ text: prompt }] }]
      }.to_json

      response = Net::HTTP.post(uri, body, headers)
      json = JSON.parse(response.body)
      json.dig("candidates", 0, "content", "parts", 0, "text") || "⚠️ AI could not generate a response."
    end
end



