class Databrief < Formula
  desc "Turn a data file into a prompt for an AI, offline, with a Do-not-share-data mode"
  homepage "https://github.com/Arfo-du-blo/DataBrief"
  url "https://github.com/Arfo-du-blo/DataBrief/releases/download/v1.6.0/databrief-cli.cjs"
  sha256 "51883918dd344c5865967d97ea5f73e2b77ccc6682038f7858bb9cb6aa839ac5"
  license "GPL-3.0-or-later"

  depends_on "node"

  resource "manpage" do
    url "https://github.com/Arfo-du-blo/DataBrief/releases/download/v1.6.0/databrief.1"
    sha256 "ee70ba4fbab770f1848fe8d582f6624d6fe113312743d4e1370f9db8e6859283"
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
