# Loads the dev-work cards from db/showcase/projects.yml and their images (same folder), and files
# the older projects under "earlier" and "bootcamp"; every project gets its started_on date.
# Safe to run again: it updates by title and only attaches an image that isn't attached yet
# (force_images re-attaches them). Each run resets the featured cards' copy, dates, featured flag,
# section and order to the file's, overriding admin edits.
# Run it with `bin/rails showcase:load`.
class ShowcaseLoader
  def initialize(dir: Rails.root.join("db/showcase"), force_images: false, out: $stdout)
    @dir = dir
    @force = force_images
    @out = out
    @data = YAML.load_file(dir.join("projects.yml"))
  end

  def call
    @data["featured"].each_with_index { |card, index| load_featured(card, index) }
    @data["older"].each { |entry| file_older(entry) }
  end

  private

  def load_featured(card, index)
    project = Project.find_or_initialize_by(title: card["title"])
    project.assign_attributes(card.slice("frame", "tags", "description", "started_on"))
    project.assign_attributes(live_url: card["live_url"], section: "work", featured: true)
    project.created_at = (index + 1).minutes.ago # re-set every run so the file's order always wins
    project.save!

    attach(project.featured_image, card["image"]) if card["image"]
    attach(project.icon, card["icon"]) if card["icon"]
    replace_screenshots(project, card["screenshots"]) if card["screenshots"]
    @out.puts "#{project.title}: saved (#{project.frame})"
  end

  def file_older(entry)
    project = Project.where("TRIM(title) = ?", entry["title"]).first
    return @out.puts("#{entry['title']}: not found, skipped") unless project

    project.update!(section: entry["section"], started_on: entry["started_on"], featured: false)
    @out.puts "#{entry['title']}: #{entry['section']}, #{project.started_on&.strftime('%b %Y')}"
  end

  def replace_screenshots(project, names)
    return if !@force && project.screenshots.attached?

    project.screenshots.purge
    names.each { |name| attach(project.screenshots, name, always: true) }
  end

  def attach(attachment, name, always: false)
    return if !always && !@force && attachment.attached?

    path = @dir.join(name)
    type = path.extname == ".png" ? "image/png" : "image/jpeg"
    File.open(path) { |io| attachment.attach(io: io, filename: name, content_type: type) }
  end
end
