# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

5.times do |i|
    Issue.create(description: "record-#{i+1}", 
        priority: [1,2,3].sample, 
        status: ['open', 'in-progress','closed', 'pending'].sample,
        submitted_by: "user-#{i+1}")
end
