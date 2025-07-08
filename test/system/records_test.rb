require "application_system_test_case"

class RecordsTest < ApplicationSystemTestCase
  setup do
    @record = records(:one)
  end

  test "visiting the index" do
    visit records_url
    assert_selector "h1", text: "Records"
  end

  test "should create record" do
    visit records_url
    click_on "New record"

    fill_in "Comments", with: @record.comments
    fill_in "Date", with: @record.date
    fill_in "Doctor rating", with: @record.doctor_rating
    check "Prescription" if @record.prescription
    fill_in "Prescription name", with: @record.prescription_name
    fill_in "Reason", with: @record.reason
    check "Test done" if @record.test_done
    fill_in "Test type", with: @record.test_type
    check "Xray done" if @record.xray_done
    click_on "Create Record"

    assert_text "Record was successfully created"
    click_on "Back"
  end

  test "should update Record" do
    visit record_url(@record)
    click_on "Edit this record", match: :first

    fill_in "Comments", with: @record.comments
    fill_in "Date", with: @record.date
    fill_in "Doctor rating", with: @record.doctor_rating
    check "Prescription" if @record.prescription
    fill_in "Prescription name", with: @record.prescription_name
    fill_in "Reason", with: @record.reason
    check "Test done" if @record.test_done
    fill_in "Test type", with: @record.test_type
    check "Xray done" if @record.xray_done
    click_on "Update Record"

    assert_text "Record was successfully updated"
    click_on "Back"
  end

  test "should destroy Record" do
    visit record_url(@record)
    accept_confirm { click_on "Destroy this record", match: :first }

    assert_text "Record was successfully destroyed"
  end
end
