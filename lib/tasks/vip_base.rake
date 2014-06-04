
namespace :vip_base do
  desc "Synchronize ILL users from VIP base"
  task :update => :environment do
    VipBase.fetch.each{|branch| IllUser.create_or_update_from_vip_base(branch)}
  end
end
