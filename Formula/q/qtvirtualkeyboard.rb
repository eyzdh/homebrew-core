class Qtvirtualkeyboard < Formula
  desc "Provides an input framework and reference keyboard frontend"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/6.10/6.10.0/submodules/qtvirtualkeyboard-everywhere-src-6.10.0.tar.xz"
  mirror "https://qt.mirror.constant.com/archive/qt/6.10/6.10.0/submodules/qtvirtualkeyboard-everywhere-src-6.10.0.tar.xz"
  mirror "https://mirrors.ukfast.co.uk/sites/qt.io/archive/qt/6.10/6.10.0/submodules/qtvirtualkeyboard-everywhere-src-6.10.0.tar.xz"
  sha256 "abb267f2682bc66d078b71fb342aca946414d3c60adb97d454308acc0ca31381"
  license all_of: [
    "GPL-3.0-only",
    "Apache-2.0",   # bundled openwnn, pinyin and tcime
    "BSD-3-Clause", # bundled tcime; *.cmake
  ]
  head "https://code.qt.io/qt/qtvirtualkeyboard.git", branch: "dev"

  livecheck do
    formula "qtbase"
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build

  depends_on "hunspell"
  depends_on "eyzdh/core/qtbase"
  depends_on "eyzdh/core/qtdeclarative"
  depends_on "eyzdh/core/qtmultimedia"
  depends_on "eyzdh/core/qtsvg"

  # TODO: preserve_rpath # https://github.com/orgs/Homebrew/discussions/2823

  def install
    rm_r("src/plugins/hunspell/3rdparty/hunspell")

    args = ["-DFEATURE_system_hunspell=ON"]
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
    (testpath/"test.qml").write <<~QML
      import QtQuick
      import QtQuick.Window
      import QtQuick.VirtualKeyboard

      Window {
        visible: true
        width: 640
        height: 480
        id: root

        InputPanel {
          id: inputPanel
          anchors.bottom: parent.bottom
          width: root.width
        }
        Timer {
          interval: 2000
          running: true
          onTriggered: Qt.quit()
        }
      }
    QML

    ENV["LC_ALL"] = "en_US.UTF-8"
    ENV["QT_QPA_PLATFORM"] = "minimal" if OS.linux?
    system Formula["qtdeclarative"].bin/"qml", "test.qml"
  end
end
