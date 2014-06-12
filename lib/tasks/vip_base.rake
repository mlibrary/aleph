
namespace :vip_base do
  desc "Synchronize ILL users from VIP base"
  task :update => :environment do
    VipBase.fetch.each do |branch| 
      ill_user = IllUser.create_or_update_from_vip_base(branch)
      ill_user.aleph_borrower if ill_user
    end
  end
end
