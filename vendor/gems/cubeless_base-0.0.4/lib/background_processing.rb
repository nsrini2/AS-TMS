module BackgroundProcessing
  private
  
  def bg_run_user_sync_job
    system_background(RAILS_ROOT,'rake bam:run_user_sync_job --trace > log/user_sync_job.log 2>&1')
  end
  
  def system_background(path,cmd)
    if ENV.member?('windir')
      system("start /D\"#{path}\" /MIN CMD.EXE \"/C #{cmd}\"")
    else
      system("echo \"cd #{path}; #{cmd}\" | at now")
    end
  end
end