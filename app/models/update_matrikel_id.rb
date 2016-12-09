class UpdateMatrikelId
  def initialize(removed_matrikel_id, new_matrikel_id, logger = nil)
    null_logger = Object.new; null_logger.define_singleton_method(:info, lambda { |_| }); null_logger.define_singleton_method(:error, lambda { |_| })
    @logger = logger || null_logger

    @removed_matrikel_id = removed_matrikel_id
    @new_matrikel_id = new_matrikel_id
  end
  attr_reader :removed_matrikel_id, :new_matrikel_id, :logger

  def call
    identity_to_update = Identity.where(:uid => removed_matrikel_id, :provider => "dtu").first

    if identity_to_update.nil?
      logger.info("No Identity with uid=#{removed_matrikel_id} and provider=dtu found. Nothing to do.")
      return
    end

    logger.info("Updating Identity (id=#{identity_to_update.id}): From uid=#{removed_matrikel_id} to uid=#{new_matrikel_id}.")
    begin
      identity_to_update.uid = new_matrikel_id
      identity_to_update.save!
    rescue => e
      logger.error("Update of Identity (id=#{identity_to_update.id}) failed (from uid=#{removed_matrikel_id} to uid=#{new_matrikel_id}). Exception: #{e.class} - #{e.message}.")
      raise
    end
  end
end
