class SynchronizeWithDtubase
  def initialize
  end

  def call
    dtubase = DtuBase.new
    reject_previosly_handled_removals(dtubase.request_removed_accounts).each do |removed_account|
      update_account(removed_account["removed_matrikel_id"], removed_account["new_matrikel_id"])
      DtubaseRemovedAccountEvent.create({:removed_matrikel_id => removed_account["removed_matrikel_id"], :new_matrikel_id => removed_account["new_matrikel_id"], :date_removed => removed_account["date_removed"]})
    end
  end

  private

  def reject_previosly_handled_removals(removals)
    removals.reject { |r| DtubaseRemovedAccountEvent.where(:removed_matrikel_id => r["removed_matrikel_id"], :new_matrikel_id => r["new_matrikel_id"]).present? }
  end

  def update_account(removed_matrikel_id, new_matrikel_id)
    UpdateMatrikelId.new(removed_matrikel_id, new_matrikel_id, Rails.logger).call
  end
end
