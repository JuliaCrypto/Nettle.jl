using BinDeps
using Compat

@BinDeps.setup

nettle = library_dependency("nettle", aliases = ["libnettle","libnettle-4-6","libnettle-6-1","libnettle-6-2"])

if is_windows()
  using WinRPM
  provides(WinRPM.RPM, "libnettle-6-2", nettle, os = :Windows )
end

if is_apple()
  using Homebrew
  provides( Homebrew.HB, "nettle", nettle, os = :Darwin )
end

provides( AptGet, "libnettle4", nettle )
provides( Yum, "nettle", nettle )

julia_usrdir = normpath(JULIA_HOME*"/../") # This is a stopgap, we need a better built-in solution to get the included libraries
libdirs = AbstractString["$(julia_usrdir)/lib"]
includedirs = AbstractString["$(julia_usrdir)/include"]
env = @compat Dict("HOGWEED_LIBS" => "-L$(libdirs[1]) -L$(BinDeps.libdir(nettle)) -lhogweed -lgmp",
       "NETTLE_LIBS" => "-L$(libdirs[1]) -L$(BinDeps.libdir(nettle)) -lnettle -lgmp",
       "LD_LIBRARY_PATH" => join([libdirs[1];BinDeps.libdir(nettle);get(ENV,"LD_LIBRARY_PATH","")],":"))

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

@compat @BinDeps.install Dict(:nettle => :nettle)
