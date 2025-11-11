class Qttranslations < Formula
  desc "Qt translation catalogs"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/6.10/6.10.0/submodules/qttranslations-everywhere-src-6.10.0.tar.xz"
  mirror "https://qt.mirror.constant.com/archive/qt/6.10/6.10.0/submodules/qttranslations-everywhere-src-6.10.0.tar.xz"
  mirror "https://mirrors.ukfast.co.uk/sites/qt.io/archive/qt/6.10/6.10.0/submodules/qttranslations-everywhere-src-6.10.0.tar.xz"
  sha256 "326e8253cfd0cb5745238117f297da80e30ce8f4c1db81990497bd388b026cde"
  license "BSD-3-Clause"
  head "https://code.qt.io/qt/qttranslations.git", branch: "dev"

  livecheck do
    formula "qtbase"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "ninja" => :build
  depends_on "eyzdh/core/qtbase" => [:build, :test]
  depends_on "eyzdh/core/qttools" => :build

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
  end

  test do
    (testpath/"CMakeLists.txt").write <<~CMAKE
      cmake_minimum_required(VERSION 4.0)
      project(test VERSION 1.0.0 LANGUAGES CXX)
      find_package(Qt6 REQUIRED COMPONENTS Core)
      qt_standard_project_setup()
      qt_add_executable(test main.cpp)
      target_link_libraries(test PRIVATE Qt6::Core)
    CMAKE

    (testpath/"main.cpp").write <<~CPP
      #undef QT_NO_DEBUG
      #include <iostream>
      #include <QLibraryInfo>
      #include <QLocale>
      #include <QTranslator>

      int main(void) {
        QTranslator translator;
        Q_ASSERT(translator.load(QLocale::Spanish, "qt", "_", QLibraryInfo::path(QLibraryInfo::TranslationsPath)));
        std::cout << translator.translate("CloseButton", "Close Tab").toStdString();
        return 0;
      }
    CPP

    system "cmake", "-S", ".", "-B", "build", "-DCMAKE_BUILD_RPATH=#{HOMEBREW_PREFIX}/lib"
    system "cmake", "--build", "build"
    assert_equal "Cerrar pestaña", shell_output("./build/test")
  end
end
