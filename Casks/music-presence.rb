# Music Presence
# Latest release: https://github.com/ungive/discord-music-presence/releases/latest
# SHAs: https://github.com/ungive/discord-music-presence/releases/download/v2.3.0/sha256sum.txt

cask "music-presence" do
  version "2.3.0"
  sha256 arm: "b7b9fbd8db72edfa24ea9aa24e00dff1e6d289d09c3e5914fb8bfff4da6cf982",
         intel: "6e119c862c3c8b5aa7cd466f6f5e524b1614ca427fdca201e08cae998d30d048"

  arch arm: "arm64", intel: "x86_64"
  url "https://github.com/ungive/discord-music-presence/releases/download/v#{version}/musicpresence-#{version}-mac-#{arch}.dmg",
    verified: "github.com/ungive/discord-music-presence"

  name "Music Presence"
  desc "The Discord music status that works with any media player"
  homepage "https://musicpresence.app"

  depends_on macos: ">= :big_sur"
  depends_on arch: [:arm64, :x86_64]

  app "Music Presence.app"

  zap trash: [
        "~/Library/Application Support/Music Presence",
        "~/Library/Preferences/app.musicpresence.desktop.plist",
      ]

  livecheck do
    url :url
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    strategy :github_latest do |json, regex|
      match = json["tag_name"]&.match(regex)
      next if match.blank?
      match[1]
    end
  end

  # FIXME remove this once the app is notarized
  postflight do
    system_command "xattr",
                   args: ["-cr", "/Applications/Music Presence.app"],
                   sudo: false
  end
end
