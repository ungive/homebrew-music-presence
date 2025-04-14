# Music Presence
# Latest release: https://github.com/ungive/discord-music-presence/releases/latest
# SHAs: https://github.com/ungive/discord-music-presence/releases/download/v2.3.0/sha256sum.txt

cask "music-presence" do
  arch arm: "arm64", intel: "x86_64"

  version "2.3.0"
  repo = "github.com/ungive/discord-music-presence"
  sha256 arm:   "b7b9fbd8db72edfa24ea9aa24e00dff1e6d289d09c3e5914fb8bfff4da6cf982",
         intel: "6e119c862c3c8b5aa7cd466f6f5e524b1614ca427fdca201e08cae998d30d048"

  url "https://#{repo}/releases/download/v#{version}/musicpresence-#{version}-mac-#{arch}.dmg",
      verified: repo.to_s
  name "Music Presence"
  desc "Discord music status that works with any media player"
  homepage "https://musicpresence.app/"

  livecheck do
    url :url
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    strategy :github_latest do |json, regex|
      match = json["tag_name"]&.match(regex)
      next if match.blank?

      match[1]
    end
  end

  depends_on macos: ">= :big_sur"
  depends_on arch: [:arm64, :x86_64]

  app "Music Presence.app"

  # FIXME: remove this once the app is notarized
  postflight do
    system_command "xattr",
                   args: ["-cr", "/Applications/Music Presence.app"],
                   sudo: false
  end

  zap trash: [
    "~/Library/Application Support/Music Presence",
    "~/Library/Preferences/app.musicpresence.desktop.plist",
  ]

  caveats do
    license "https://#{repo}/blob/v#{version}/LICENSE.md"
  end
end
