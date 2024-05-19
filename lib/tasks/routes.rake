# typed: false
# frozen_string_literal: true

require_relative("../kirei")

namespace :kirei do
  desc "Prints all available routes"
  task :routes do
    router = Kirei::Routing::Router.instance

    longest_path = router.routes.keys.map(&:length).max

    routes_by_controller = router.routes.values.group_by(&:controller)

    puts "\n"

    routes_by_controller.each do |controller, routes|
      puts "#{controller}:"
      routes.each do |route|
        verb = route.verb.serialize.upcase.ljust(7 + 3) # 7 is the length of the longest verb
        puts "#{verb} #{route.path.ljust(longest_path + 1)} => ##{route.action}"
      end
      puts "\n"
    end
  end
end
