# Boot check: the app loads, the stylesheet compiles, and every ERB view compiles.
# It catches the breakages a view or SCSS change can cause without a database or a browser.
# It does NOT render pages with data; walk the changed routes for that (docs/dev.md).
#
# Usage: bin/rails runner scripts/check-boot.rb   (with the rbenv Ruby, see docs/dev.md)

failures = []

begin
  Rails.application.eager_load!
  puts "eager_load: OK"
rescue StandardError, SyntaxError => e
  failures << "eager_load: #{e.class}: #{e.message}"
end

begin
  css = Rails.application.assets["application.css"].to_s
  # Production also squeezes the finished CSS through Sass (sassc-rails' compressor). Plain CSS that
  # compiles fine can still fail there, e.g. min(340px, 100%) ("Incompatible units"), and that
  # rejects the Heroku build. Run the same pass here.
  SassC::Engine.new(css, syntax: :scss, style: :compressed).render
  puts "application.css: OK (#{css.bytesize} bytes, production compress OK)"
rescue StandardError => e
  failures << "application.css: #{e.class}: #{e.message}"
end

views = Dir[Rails.root.join("app/views/**/*.erb")]
views.each do |path|
  code = ActionView::Template::Handlers::ERB::Erubi.new(File.read(path)).src
  # Wrapped in a method so a layout's `yield` compiles.
  RubyVM::InstructionSequence.compile("def __view\n#{code}\nend")
rescue SyntaxError, StandardError => e
  failures << "#{path.delete_prefix("#{Rails.root}/")}: #{e.message.lines.first&.strip}"
end
puts "views: #{views.size - failures.count { |f| f.start_with?('app/views') }}/#{views.size} compile"

if failures.any?
  warn "\n✖ boot check failed:"
  failures.each { |f| warn "  #{f}" }
  exit 1
end
puts "boot check: OK"
