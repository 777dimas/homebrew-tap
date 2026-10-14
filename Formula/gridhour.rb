class Gridhour < Formula
  include Language::Python::Virtualenv

  desc "When UK electricity is green and cheap: carbon and Octopus prices in your terminal"
  homepage "https://github.com/777dimas/gridhour"
  url "https://files.pythonhosted.org/packages/83/4a/c8b86018c69111072b7884d239eee0d4d46455a4f0984dcdacea88ecb38c/gridhour-0.4.2.tar.gz"
  sha256 "a9a67b905d274e3fb951f81c48c322afe3909a46662e097b1bef20f00ea75ece"
  license "MIT"

  depends_on "python@3.13"

  # gridhour has no runtime dependencies; setuptools is only needed to build it from the sdist
  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/6d/44/f5da03a8ef95d369145c5bb53050e7877c9f3d312e128605fd9504829143/setuptools-84.0.0.tar.gz"
    sha256 "f4695c21257f0d9b537ec2692c941d02ee143b7cc1276941349a546573b2ef73"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gridhour --version")
    # no network in the test sandbox: it must say so and still exit cleanly
    ENV["GRIDHOUR_OFFLINE"] = "1"
    ENV["XDG_CONFIG_HOME"] = testpath/"config"
    ENV["XDG_CACHE_HOME"] = testpath/"cache"
    assert_match "offline", shell_output("#{bin}/gridhour SW1A --line")
  end
end
