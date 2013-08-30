using BinDeps

@BinDeps.setup

nettle = library_dependency("nettle", aliases = ["libnettle"])

@windows_only begin
  Pkg.installed("RPMmd") === nothing && Pkg.add("RPMmd")
  using RPMmd
  provides(RPMmd.RPM, "libnettle", nettle, os = :Windows )
end

@osx_only begin
  Pkg.installed("Homebrew") === nothing && Pkg.add("Homebrew")
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
       "LIBS" => "-lgmp ", "LD_LIBRARY_PATH" => join([libdirs[1];BinDeps.libdir(nettle)],":")}

provides( Sources, URI("http://www.lysator.liu.se/~nisse/archive/nettle-2.7.tar.gz"), nettle )
provides( BuildProcess, Autotools(lib_dirs = libdirs, include_dirs = includedirs, env = env), nettle )

@BinDeps.install
