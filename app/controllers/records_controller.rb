class RecordsController < ApplicationController
  before_action :set_record, only: %i[ show edit update destroy ]

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

  private

    def set_record
      @record = Record.find(params[:id])
    end

    def authorize_record!
      redirect_to records_path, alert: "Not authorized." unless @record.user == current_user
    end

    def record_params
      params.require(:record).permit(:date, :reason, :image, :prescription, :prescription_name, :xray_done, :test_done, :test_type, :doctor_rating, :comments)
    end
end

