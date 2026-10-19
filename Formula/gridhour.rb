class Gridhour < Formula
  include Language::Python::Virtualenv

  desc "When UK electricity is green and cheap: carbon and Octopus prices in your terminal"
  homepage "https://github.com/777dimas/gridhour"
  url "https://files.pythonhosted.org/packages/9c/15/619e32bd3f4fb6fe93cc53fb9e2e73ffda1f3d270d45156f30992841a9ce/gridhour-0.5.0.tar.gz"
  sha256 "93c1737205dde2308d0545600b6f663ad6ced487ff2710eb8fbfd8e1bb5d6948"
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
