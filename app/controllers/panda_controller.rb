class PandaController < ApplicationController
  def authorize_upload
      Rails.logger.info("Authorizing:" + params['payload'].to_s)
      payload = JSON.parse(params['payload'])
      upload = Panda.post('/videos/upload.json', {
        :file_name => payload['filename'],
        :file_size => payload['filesize'],
        :profiles => "h264"
      })

      render :json => {:upload_url => upload['location']}
    end
  end
