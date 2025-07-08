json.extract! record, :id, :date, :reason, :image, :prescription, :prescription_name, :xray_done, :test_done, :test_type, :doctor_rating, :comments, :created_at, :updated_at
json.url record_url(record, format: :json)
json.image url_for(record.image)
