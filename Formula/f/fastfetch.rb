class Fastfetch < Formula
  desc "Like neofetch, but much faster because written mostly in C"
  homepage "https://github.com/fastfetch-cli/fastfetch"
  url "https://github.com/fastfetch-cli/fastfetch/archive/refs/tags/2.55.0.tar.gz"
  sha256 "d99ea4f5398ef05059771aa0b1aeda4bc1d01d951ae91d93c5b6dfb550649dbe"
  license "MIT"
  head "https://github.com/fastfetch-cli/fastfetch.git", branch: "dev"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256                               arm64_tahoe:   "9f218f98f166fc849ec6ca2aae405466df21fe380c3e3d9d53ec53a299baa055"
    sha256                               arm64_sequoia: "4979552992daef909878c011fb0eb752887d8c490dc11287c4a731cb648c1548"
    sha256                               arm64_sonoma:  "8c383b00f7c7d136286a2b072a81c1558c0f649a9791754281f587c2b10ef152"
    sha256 cellar: :any_skip_relocation, sonoma:        "5e6ec460f83c8a70009afe6f2678ebf53d4a4ac772aa843c4f191924de281b3d"
    sha256                               arm64_linux:   "59d97eac1ef726451e138cb249a8fe145365bc1dc07c39a4ba30e03a1534ac55"
    sha256                               x86_64_linux:  "424c53ca9d6a4c6756ab384d0662242d17e4d485187af4bb9e98ded87b1bc143"
  end

  depends_on "chafa" => :build
  depends_on "cmake" => :build
  depends_on "glib" => :build
  depends_on "imagemagick" => :build
  depends_on "pkgconf" => :build
  depends_on "python@3.14" => :build
  depends_on "vulkan-loader" => :build

  uses_from_macos "sqlite" => :build
  uses_from_macos "zlib" => :build

  on_linux do
    depends_on "dbus" => :build
    depends_on "ddcutil" => :build
    depends_on "elfutils" => :build
    depends_on "libdrm" => :build
    depends_on "libx11" => :build
    depends_on "libxcb" => :build
    depends_on "libxrandr" => :build
    depends_on "mesa" => :build
    depends_on "opencl-icd-loader" => :build
    depends_on "pulseaudio" => :build
    depends_on "rpm" => :build
    depends_on "wayland" => :build
  end

  def install
    args = %W[
      -DCMAKE_INSTALL_SYSCONFDIR=#{etc}
      -DBUILD_FLASHFETCH=OFF
      -DENABLE_SYSTEM_YYJSON=OFF
    ]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    bash_completion.install share/"bash-completion/completions/fastfetch"
  end

  test do
    assert_match "fastfetch", shell_output("#{bin}/fastfetch --version")
    assert_match "OS", shell_output("#{bin}/fastfetch --structure OS --pipe")
  end
end
