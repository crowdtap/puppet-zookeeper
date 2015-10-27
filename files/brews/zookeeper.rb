require "formula"

class Zookeeper < Formula
  homepage "https://zookeeper.apache.org/"
  version "3.4.6-boxen3"

  stable do
    url "http://www.apache.org/dyn/closer.cgi?path=zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz"
    sha256 "01b3938547cd620dc4c93efe07c0360411f4a66962a70500b163b59014046994"

    # To resolve >= Yosemite build errors.
    # https://issues.apache.org/jira/browse/ZOOKEEPER-2049
    if MacOS.version >= :yosemite
      patch :p0 do
        url "https://issues.apache.org/jira/secure/attachment/12673210/ZOOKEEPER-2049.noprefix.branch-3.4.patch"
        sha256 "b90eda47d21e60655dffe476eb437400afed24b37bbd71e7291faa8ece35c62b"
      end
    end
  end

  head do
    url "https://svn.apache.org/repos/asf/zookeeper/trunk"

    # To resolve >= Yosemite build errors.
    # https://issues.apache.org/jira/browse/ZOOKEEPER-2049
    if MacOS.version >= :yosemite
      patch :p0 do
        url "https://issues.apache.org/jira/secure/attachment/12673212/ZOOKEEPER-2049.noprefix.trunk.patch"
        sha256 "64b5a4279a159977cbc1a1ab8fe782644f38ed04489b5a294d53aea74c84db89"
      end
    end

    depends_on "ant" => :build
    depends_on "cppunit" => :build
    depends_on "libtool" => :build
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  option "perl", "Build Perl bindings"

  depends_on :python => :optional

  def install
    # Don't try to build extensions for PPC
    if Hardware.is_32_bit?
      ENV["ARCHFLAGS"] = "-arch #{Hardware::CPU.arch_32_bit}"
    else
      ENV["ARCHFLAGS"] = Hardware::CPU.universal_archs.as_arch_flags
    end

    if build.head?
      system "ant", "compile_jute"
      system "autoreconf", "-fvi", "src/c"
    end

    cd "src/c" do
      system "./configure", "--disable-dependency-tracking",
                            "--prefix=#{prefix}",
                            "--without-cppunit"
      system "make", "install"
    end

    cd "src/contrib/zkpython" do
      system "python", "src/python/setup.py", "build"
      system "python", "src/python/setup.py", "install", "--prefix=#{prefix}"
    end if build.with? "python"

    cd "src/contrib/zkperl" do
      system "perl", "Makefile.PL", "PREFIX=#{prefix}",
                                    "--zookeeper-include=#{include}",
                                    "--zookeeper-lib=#{lib}"
      system "make", "install"
    end if build.include? "perl"

    rm_f Dir["bin/*.cmd"]

    if build.head?
      system "ant"
      libexec.install Dir["bin", "src/contrib", "src/java/lib", "build/*.jar"]
    else
      libexec.install Dir["bin", "contrib", "lib", "*.jar"]
    end
  end

  plist_options :manual => "zkServer start"
end
