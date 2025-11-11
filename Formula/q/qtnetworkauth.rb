class Qtnetworkauth < Formula
  desc "Provides support for OAuth-based authorization to online services"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/6.10/6.10.0/submodules/qtnetworkauth-everywhere-src-6.10.0.tar.xz"
  mirror "https://qt.mirror.constant.com/archive/qt/6.10/6.10.0/submodules/qtnetworkauth-everywhere-src-6.10.0.tar.xz"
  mirror "https://mirrors.ukfast.co.uk/sites/qt.io/archive/qt/6.10/6.10.0/submodules/qtnetworkauth-everywhere-src-6.10.0.tar.xz"
  sha256 "0460855d71e22d1f08045c9577c3ab09790b78f9de263405c2b9b00f6c33b3c8"
  license all_of: [
    "GPL-3.0-only",
    "BSD-3-Clause", # *.cmake
  ]
  head "https://code.qt.io/qt/qtnetworkauth.git", branch: "dev"

  livecheck do
    formula "qtbase"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "ninja" => :build
  depends_on "pkgconf" => :test

  depends_on "eyzdh/core/qtbase"

  # TODO: preserve_rpath # https://github.com/orgs/Homebrew/discussions/2823

  def install
    args = []
    if OS.mac?
      args << "-DQT_EXTRA_RPATHS=#{(HOMEBREW_PREFIX/"lib").relative_path_from(lib)}"
      args << "-DQT_NO_APPLE_SDK_AND_XCODE_CHECK=ON"
    end

    system "cmake", "-S", ".", "-B", "build", "-G", "Ninja", *args, *std_cmake_args(find_framework: "FIRST")
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # Some config scripts will only find Qt in a "Frameworks" folder
    frameworks.install_symlink lib.glob("*.framework") if OS.mac?
  end

  test do
    (testpath/"CMakeLists.txt").write <<~CMAKE
      cmake_minimum_required(VERSION 4.0)
      project(test VERSION 1.0.0 LANGUAGES CXX)
      find_package(Qt6 REQUIRED COMPONENTS NetworkAuth)
      qt_standard_project_setup()
      qt_add_executable(test main.cpp)
      target_link_libraries(test PRIVATE Qt6::NetworkAuth)
    CMAKE

    (testpath/"test.pro").write <<~QMAKE
      QT      += networkauth
      TARGET   = test
      CONFIG  += console
      CONFIG  -= app_bundle
      TEMPLATE = app
      SOURCES += main.cpp
    QMAKE

    (testpath/"main.cpp").write <<~CPP
      #undef QT_NO_DEBUG
      #include <QHostAddress>
      #include <QOAuth2AuthorizationCodeFlow>
      #include <QOAuthHttpServerReplyHandler>

      int main(void) {
        QOAuth2AuthorizationCodeFlow oauth2;
        auto replyHandler = new QOAuthHttpServerReplyHandler(QHostAddress::Any, 1337);
        oauth2.setReplyHandler(replyHandler);
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

    flags = shell_output("pkgconf --cflags --libs Qt6NetworkAuth").chomp.split
    system ENV.cxx, "-std=c++17", "main.cpp", "-o", "test", *flags, "-Wl,-rpath,#{HOMEBREW_PREFIX}/lib"
    system "./test"
  end
end
