# Presentation bits for project cards: the device frame's brand colour, the address shown in the
# browser bar, and the terminal card's lines.
module ProjectsHelper
  # The wash of colour behind each device, keyed by project title (case-insensitive).
  ACCENTS = {
    "menyu" => "#1D5E53",
    "sollo" => "#26345C",
    "mytap" => "#1E4E96",
    "alturaflow" => "#0E1A14",
    "imagebank-reader" => "#2A2522",
    "cs12 skincare" => "#9C7A3C",
    "ys club" => "#2F6DB5"
  }.freeze

  # The rescue route that worked (tools/bank2dng.py decoding the pulled disk), in the script's own
  # print formats. No run was ever captured, so slots and file names are illustrative; 91 is the real
  # count of photos it brought back. No vendor names: the repo deliberately leaves them out.
  TERMINAL_LINES = {
    "imagebank-reader" => [
      "$ bank2dng.py bank.img out --year 2024",
      "CFA phase detected on slot 21: GRBG",
      "slot    21 -> 0001.dng",
      "slot    22 -> 0002.dng",
      "...",
      "91 files written to out",
      "$ _"
    ]
  }.freeze

  def project_accent(project)
    ACCENTS.fetch(project.title.to_s.strip.downcase, "#8D0B41")
  end

  def project_host(project)
    return "" if project.live_url.blank?

    URI.parse(project_live_url(project)).host.to_s.delete_prefix("www.")
  rescue URI::InvalidURIError
    ""
  end

  # Old records store bare domains ("tokyoturntable.com"); links need a scheme.
  def project_live_url(project)
    url = project.live_url.to_s.strip
    url.start_with?("http") ? url : "https://#{url}"
  end

  # The app card's short line: whole sentences from the description until it has at least 40
  # characters (a short first sentence like "Life in Japan, explained." alone is too thin).
  def project_tagline(project)
    sentences = project.description.to_s.squish.split(/(?<=[.!?])\s+/)
    sentences.each_with_object(+"") do |sentence, line|
      line << " " unless line.empty?
      line << sentence
      break line if line.length >= 40
    end
  end

  def terminal_lines(project)
    TERMINAL_LINES.fetch(project.title.to_s.strip.downcase, ["$ #{project.title.strip}", "$ _"])
  end
end
