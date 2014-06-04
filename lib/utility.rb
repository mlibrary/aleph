class Utility
  # Logs exception
  # Optional args:
  # info: "A descriptive messsage"
  def self.log_exception e, args
    extra_info = args[:info]

    Rails.logger.error extra_info if extra_info
    Rails.logger.error e.message
    st = e.backtrace.join("\n")
    Rails.logger.error st
  end
end
