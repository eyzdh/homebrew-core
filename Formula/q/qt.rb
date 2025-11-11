class Qt < Formula
  desc "Cross-platform application and UI framework"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/6.10/6.10.0/submodules/md5sums.txt"
  mirror "https://qt.mirror.constant.com/archive/qt/6.10/6.10.0/submodules/md5sums.txt"
  mirror "https://mirrors.ukfast.co.uk/sites/qt.io/archive/qt/6.10/6.10.0/submodules/md5sums.txt"
  version "6.10.0"
  sha256 "f84e7f1240469b4af7cb2695eda67f4f181cc50d24e615a10f223371379858ab"
  license all_of: [
    "BSD-3-Clause",
    "GFDL-1.3-no-invariants-only",
    "GPL-2.0-only",
    { "GPL-3.0-only" => { with: "Qt-GPL-exception-1.0" } },
    "LGPL-3.0-only",
  ]

  livecheck do
    formula "qtbase"
  end

  depends_on "cmake" => :test
depends_on "pkgconf" => :test
depends_on "vulkan-headers" => :test

depends_on "eyzdh/core/qt3d"
depends_on "eyzdh/core/qt5compat"
depends_on "eyzdh/core/qtbase"
depends_on "eyzdh/core/qtcharts"
depends_on "eyzdh/core/qtconnectivity"
depends_on "eyzdh/core/qtdatavis3d"
depends_on "eyzdh/core/qtdeclarative"
depends_on "eyzdh/core/qtgraphs"
depends_on "eyzdh/core/qtgrpc"
depends_on "eyzdh/core/qthttpserver"
depends_on "eyzdh/core/qtimageformats"
depends_on "eyzdh/core/qtlanguageserver"
depends_on "eyzdh/core/qtlocation"
depends_on "eyzdh/core/qtlottie"
depends_on "eyzdh/core/qtmultimedia"
depends_on "eyzdh/core/qtnetworkauth"
depends_on "eyzdh/core/qtpositioning"
depends_on "eyzdh/core/qtquick3d"
depends_on "eyzdh/core/qtquick3dphysics"
depends_on "eyzdh/core/qtquickeffectmaker"
depends_on "eyzdh/core/qtquicktimeline"
depends_on "eyzdh/core/qtremoteobjects"
depends_on "eyzdh/core/qtscxml"
depends_on "eyzdh/core/qtsensors"
depends_on "eyzdh/core/qtserialbus"
depends_on "eyzdh/core/qtserialport"
depends_on "eyzdh/core/qtshadertools"
depends_on "eyzdh/core/qtspeech"
depends_on "eyzdh/core/qtsvg"
depends_on "eyzdh/core/qttools"
depends_on "eyzdh/core/qttranslations"
depends_on "eyzdh/core/qtvirtualkeyboard"
depends_on "eyzdh/core/qtwebchannel"
depends_on "eyzdh/core/qtwebsockets"

on_system :linux, macos: :sonoma_or_newer do
  depends_on "eyzdh/core/qtwebengine"
  depends_on "eyzdh/core/qtwebview"
end

on_linux do
  depends_on "eyzdh/core/qtwayland"
end

  on_linux do
    depends_on "qtwayland"
  end

  def install
    # Check for any new formulae that need to be created before bottling
    if build.bottle?
      submodules = File.read("md5sums.txt").scan(/^\h+[ \t]+(\S+)-everywhere-src-/i).flatten.to_set
      submodules -= ["qtwebengine", "qtwebview"] if OS.mac? && MacOS.version < :sonoma
      submodules.delete("qtwayland") unless OS.linux?
      submodules.delete("qtactiveqt") # Windows-only
      submodules.delete("qtdoc") # skip HTML documentation

      dep_names = deps.reject(&:test?).to_set(&:name)
      missing = submodules - dep_names
      odie "Possible new #{Utils.pluralize("formula", missing.count)}: #{missing.join(", ")}" unless missing.empty?
      extras = dep_names - submodules
      odie "Unexpected #{Utils.pluralize("dependency", extras.count)}: #{extras.join(", ")}" unless extras.empty?
    end

    # Create compatibility symlinks so existing usage of `Formula["qt"]` still works.
    # These are done pointing to HOMEBREW_PREFIX paths to avoid making `qt` keg-only
    # which causes an unwanted caveat message. Anyways, Qt won't work correctly if
    # any dependencies are not linked as it is built to find modules in linked path
    deps.each do |dep|
      next if dep.test?

      formula = dep.to_formula
      Find.find(*formula.opt_prefix.glob("{#{Keg.keg_link_directories.join(",")}}")) do |src|
        src = Pathname(src)
        dst = prefix/src.relative_path_from(formula.opt_prefix)
        linked_src = HOMEBREW_PREFIX/src.relative_path_from(formula.opt_prefix)

        # Skip directories that have been symlinked already. We just link all directories
        # starting with "Qt", which helps reduce the total number of symlinks by over 90%.
        Find.prune if dst.symlink?

        if src.symlink? || src.file?
          dst.dirname.install_symlink linked_src
        elsif src.directory? && (linked_src.symlink? || src.basename.to_s.start_with?(/qt/i))
          dst.dirname.install_symlink linked_src
          Find.prune
        end
      end

      # Also symlink apps from libexec directories. Need to use ln_s to retain opt path
      formula.opt_libexec.glob("*.app") do |app|
        libexec.mkpath
        ln_s app.relative_path_from(libexec), libexec
      end
    end
  end

  test do
    webengine_supported = !OS.mac? || MacOS.version > :ventura
    modules = %w[Core Gui Widgets Sql Concurrent 3DCore Svg Quick3D Network NetworkAuth]
    modules << "WebEngineCore" if webengine_supported

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
      INCLUDEPATH += #{Formula["vulkan-headers"].opt_include}
    QMAKE

    (testpath/"main.cpp").write <<~CPP
      #undef QT_NO_DEBUG
      #include <QCoreApplication>
      #include <Qt3DCore>
      #include <QtQuick3D>
      #include <QImageReader>
      #include <QtNetworkAuth>
      #include <QtSql>
      #include <QtSvg>
      #include <QDebug>
      #include <QVulkanInstance>
      #{"#include <QtWebEngineCore>" if webengine_supported}
      #include <iostream>

      int main(int argc, char *argv[])
      {
        QCoreApplication app(argc, argv);
        QSvgGenerator generator;
        auto *handler = new QOAuthHttpServerReplyHandler();
        delete handler; handler = nullptr;
        auto *root = new Qt3DCore::QEntity();
        delete root; root = nullptr;
        Q_ASSERT(QSqlDatabase::isDriverAvailable("QSQLITE"));
        const auto &list = QImageReader::supportedImageFormats();
        QVulkanInstance inst;
        // See https://github.com/actions/runner-images/issues/1779
        // if (!inst.create())
        //   qFatal("Failed to create Vulkan instance: %d", inst.errorCode());
        for(const char* fmt:{"bmp", "cur", "gif",
          #ifdef __APPLE__
            "heic", "heif",
          #endif
          "icns", "ico", "jp2", "jpeg", "jpg", "pbm", "pgm", "png",
          "ppm", "svg", "svgz", "tga", "tif", "tiff", "wbmp", "webp",
          "xbm", "xpm"}) {
          Q_ASSERT(list.contains(fmt));
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
      system bin/"qmake", testpath/"test.pro"
      system "make"
      system "./test"
    end

    flags = shell_output("pkgconf --cflags --libs Qt6#{modules.join(" Qt6")}").chomp.split
    system ENV.cxx, "-std=c++17", "main.cpp", "-o", "test", *flags, "-Wl,-rpath,#{HOMEBREW_PREFIX}/lib"
    system "./test"

    # Check QT_INSTALL_PREFIX is HOMEBREW_PREFIX to support split `qt-*` formulae
    assert_equal HOMEBREW_PREFIX.to_s, shell_output("#{bin}/qmake -query QT_INSTALL_PREFIX").chomp
  end
end
