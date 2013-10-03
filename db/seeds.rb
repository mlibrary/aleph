# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the
# db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
[
  { code: 'student', :aleph_bor_status => '88', :aleph_bor_type => '05' },
  { code: 'private', :aleph_bor_status => '09', :aleph_bor_type => '06' },
  { code: 'dtu_empl', :aleph_bor_status => '18', :aleph_bor_type => '08' },
  { code: 'library', :aleph_bor_status => '02', :aleph_bor_type => '01' },
].each do |usertype|
  UserType.find_or_create_by_code(usertype)
end
