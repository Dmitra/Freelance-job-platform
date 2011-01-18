module ModelsHelper
  def skip_timestamping
    self.record_timestamps = false
    yield
    self.record_timestamps = true
  end
end
