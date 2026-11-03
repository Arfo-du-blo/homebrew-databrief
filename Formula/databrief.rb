class Databrief < Formula
  desc "Turn a data file into a prompt for an AI, offline, with a Do-not-share-data mode"
  homepage "https://github.com/Arfo-du-blo/DataBrief"
  url "https://github.com/Arfo-du-blo/DataBrief/releases/download/v1.5.0/databrief-cli.cjs"
  sha256 "882565c5acba36124b746e8c538dc6a19b766453d59f4889243a13a1bd44312d"
  license "GPL-3.0-or-later"

  depends_on "node"

  resource "manpage" do
    url "https://github.com/Arfo-du-blo/DataBrief/releases/download/v1.5.0/databrief.1"
    sha256 "670b4deb4af42f98eec898a847f3021cd43398be454b216596d5e65164fb1ef2"
  end

  def install
    libexec.install "databrief-cli.cjs"
    (bin/"databrief").write <<~SH
      #!/bin/bash
      exec "#{Formula["node"].opt_bin}/node" "#{libexec}/databrief-cli.cjs" "$@"
    SH
    chmod 0555, bin/"databrief"
    resource("manpage").stage { man1.install "databrief.1" }
  end

  test do
    assert_match "databrief #{version}", shell_output("#{bin}/databrief --version")

    (testpath/"people.csv").write("name,amount\nZelda,12\nBo,8\n")
    shared = shell_output("#{bin}/databrief #{testpath}/people.csv --print --no-copy --quiet")
    assert_match "Zelda", shared

    private_prompt = shell_output("#{bin}/databrief #{testpath}/people.csv --print --no-copy --quiet --no-share")
    assert_match "data not shared", private_prompt
    refute_match "Zelda", private_prompt
  end
end
