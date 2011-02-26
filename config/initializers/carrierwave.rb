CarrierWave.configure do |config|
  config.s3_access_key_id = ENV['S3_KEY']
  config.s3_secret_access_key = ENV['S3_SECRET']
  config.s3_bucket = 'currmap'
  
  if false
    if Rails.env.production?
      config.storage = :s3
      config.s3_access_key_id = 'YOUR_S3_ACCESS_KEY'
      config.s3_secret_access_key = 'YOUR_S3_SECRET_ACCESS_KEY'
      config.s3_bucket = 'BUCKET_NAME'
      config.s3_cnamed = true
    elsif Rails.env.development?
      config.storage = :file
    else
      config.storage = :file
      config.enable_processing = false
    end
  end
end