require "net/http"
require "json"

class RecordsController < ApplicationController
  before_action :set_record, only: %i[show edit update destroy doctor_suggestion]

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

    # Create Gemini prompt with full record context
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


