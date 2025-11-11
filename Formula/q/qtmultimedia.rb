class Qtmultimedia < Formula
  desc "Provides APIs for playing back and recording audiovisual content"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/6.10/6.10.0/submodules/qtmultimedia-everywhere-src-6.10.0.tar.xz"
  mirror "https://qt.mirror.constant.com/archive/qt/6.10/6.10.0/submodules/qtmultimedia-everywhere-src-6.10.0.tar.xz"
  mirror "https://mirrors.ukfast.co.uk/sites/qt.io/archive/qt/6.10/6.10.0/submodules/qtmultimedia-everywhere-src-6.10.0.tar.xz"
  sha256 "04424021cf0d1d19799f5967310d484d1afa6fdd0b31725d0ee7608d2eef1126"
  license all_of: [
    { any_of: ["LGPL-3.0-only", "GPL-2.0-only", "GPL-3.0-only"] },
    { all_of: ["MPL-2.0", "BSD-3-Clause"] }, # bundled eigen
    "Apache-2.0",   # bundled resonance-audio
    "BSD-3-Clause", # bundled pffft; *.cmake
    "GPL-3.0-only", # Qt6MultimediaTestLib
    "MIT",          # bundled signalsmith-stretch (Linux)
  ]
  head "https://code.qt.io/qt/qtmultimedia.git", branch: "dev"

  livecheck do
    formula "qtbase"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "ninja" => :build
  depends_on "qtshadertools" => :build
  depends_on "vulkan-headers" => :build
  depends_on "pkgconf" => :test

  depends_on macos: :ventura
  depends_on "qtbase"
  depends_on "qtdeclarative"
  depends_on "qtquick3d"

  on_macos do
    depends_on "qtshadertools"
  end

  on_ventura do
    depends_on xcode: ["15.0", :build] # for `@available(macOS 14)`
  end

  on_linux do
    depends_on "ffmpeg"
    depends_on "glib"
    depends_on "gstreamer"
    depends_on "libx11"
    depends_on "libxext"
    depends_on "libxrandr"
    depends_on "mesa"
    depends_on "pulseaudio"
  end

  # TODO: preserve_rpath # https://github.com/orgs/Homebrew/discussions/2823

  def install
    args = []
    if OS.mac?
      args += %W[
        -DQT_EXTRA_RPATHS=#{(HOMEBREW_PREFIX/"lib").relative_path_from(lib)}
        -DQT_FEATURE_ffmpeg=OFF
        -DQT_NO_APPLE_SDK_AND_XCODE_CHECK=ON
      ]
    end

    system "cmake", "-S", ".", "-B", "build", "-G", "Ninja", *args, *std_cmake_args(find_framework: "FIRST")
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # Some config scripts will only find Qt in a "Frameworks" folder
    frameworks.install_symlink lib.glob("*.framework") if OS.mac?
  end

  test do
    modules = %w[Core Multimedia]

    (testpath/"CMakeLists.txt").write <<~CMAKE
      cmake_minimum_required(VERSION 4.0)
      project(test VERSION 1.0.0 LANGUAGES CXX)
      find_package(Qt6 REQUIRED COMPONENTS #{modules.join(" ")})
      qt_standard_project_setup()
      qt_add_executable(test main.cpp)
      target_link_libraries(test PRIVATE Qt6::#{modules.join(" Qt6::")})
    CMAKE

    (testpath/"test.pro").write <<~QMAKE
      QT      += #{modules.join(" ").downcase}
      TARGET   = test
      CONFIG  += console
      CONFIG  -= app_bundle
      TEMPLATE = app
      SOURCES += main.cpp
    QMAKE

    (testpath/"main.cpp").write <<~CPP
      #include <QCoreApplication>
      #include <QAudioDevice>
      #include <QMediaDevices>
      #include <QTextStream>

      int main(int argc, char *argv[]) {
        QCoreApplication app(argc, argv);
        QTextStream out(stdout);
        for(const QAudioDevice &device : QMediaDevices::audioInputs()) {
          out << "ID: " << device.id() << Qt::endl;
        }
        return 0;
      }
    CPP

    ENV["LC_ALL"] = "en_US.UTF-8"
    ENV["QT_QPA_PLATFORM"] = "minimal" if OS.linux? && ENV["HOMEBREW_GITHUB_ACTIONS"]

    system "cmake", "-S", ".", "-B", "cmake", "-DCMAKE_BUILD_RPATH=#{HOMEBREW_PREFIX}/lib"
    system "cmake", "--build", "cmake"
    system "./cmake/test"

    ENV.delete "CPATH" if OS.mac?
    mkdir "qmake" do
      system Formula["qtbase"].bin/"qmake", testpath/"test.pro"
      system "make"
      system "./test"
    end

    flags = shell_output("pkgconf --cflags --libs Qt6#{modules.join(" Qt6")}").chomp.split
    system ENV.cxx, "-std=c++17", "main.cpp", "-o", "test", *flags, "-Wl,-rpath,#{HOMEBREW_PREFIX}/lib"
    system "./test"
  end
end
