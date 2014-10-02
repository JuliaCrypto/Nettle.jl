using BinDeps

@BinDeps.setup

nettle = library_dependency("nettle", aliases = ["libnettle","libnettle-4-6"])

@windows_only begin
  using WinRPM
  provides(WinRPM.RPM, "libnettle-4-6", nettle, os = :Windows )
end

@osx_only begin
  using Homebrew
  provides( Homebrew.HB, "nettle", nettle, os = :Darwin )
end

provides( AptGet, "libnettle4", nettle )
provides( Yum, "nettle", nettle )

julia_usrdir = normpath(JULIA_HOME*"/../") # This is a stopgap, we need a better builtin solution to get the included libraries
libdirs = String["$(julia_usrdir)/lib"]
includedirs = String["$(julia_usrdir)/include"]
env = {"HOGWEED_LIBS" => "-L$(libdirs[1]) -L$(BinDeps.libdir(nettle)) -lhogweed -lgmp",
       "NETTLE_LIBS" => "-L$(libdirs[1]) -L$(BinDeps.libdir(nettle)) -lnettle -lgmp",
       "LD_LIBRARY_PATH" => join([libdirs[1];BinDeps.libdir(nettle)],":")}

provides( Sources,
          URI("http://www.lysator.liu.se/~nisse/archive/nettle-2.7.1.tar.gz"),
          SHA="bc71ebd43435537d767799e414fce88e521b7278d48c860651216e1fc6555b40",
          nettle )
provides( BuildProcess,
          Autotools(lib_dirs = libdirs,
                    include_dirs = includedirs,
                    env = env,
                    configure_options = ["--disable-openssl", "--libdir=$(BinDeps.libdir(nettle))"]),
          nettle )

@BinDeps.install [:nettle => :nettle]
