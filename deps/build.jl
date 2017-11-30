using BinaryProvider

# BinaryProvider support
const prefix = Prefix(joinpath(dirname(dirname(@__FILE__)),"deps","usr"))
 
# We only care about libnettle, get it put into our `deps.jl` file:
libnettle = LibraryProduct(prefix, "libnettle")
# We're also going to find `nettle-hash` and `nettle.pc` for completeness
nettlehash = ExecutableProduct(prefix, "nettle-hash")
nettlepc = FileProduct(joinpath(libdir(prefix), "pkgconfig", "nettle.pc"))

# This is where we download things from, for different platforms
bin_prefix="https://github.com/staticfloat/NettleBuilder/releases/download/v3.3-0"
download_info = Dict(
    aarch64-linux-gnu => ("$bin_prefix/nettle.aarch64-linux-gnu.tar.gz", "c72acc17ea74d3b856f506a850dd1cc5c889edffcf085b613286c2a87099a2a0"),
    arm-linux-gnueabihf => ("$bin_prefix/nettle.arm-linux-gnueabihf.tar.gz", "8b1255439c42c5655b1d88851efebc9c4111ea8b185b3344e1b5e5873ffdcd8c"),
    i686-linux-gnu => ("$bin_prefix/nettle.i686-linux-gnu.tar.gz", "454576816ddd2bb9b40e4d63710231f084699d3b728ab6c6c670e8615a4ffdbb"),
    i686-w64-mingw32 => ("$bin_prefix/nettle.i686-w64-mingw32.tar.gz", "c5841c2d0373288ceb9ce07586130bab3564352248b8753474b6af03503820d7"),
    powerpc64le-linux-gnu => ("$bin_prefix/nettle.powerpc64le-linux-gnu.tar.gz", "10eb5abd3058c3988a397497eadea2f48c8e1b00b66db82f2a80fa00ed5494d8"),
    x86_64-apple-darwin14 => ("$bin_prefix/nettle.x86_64-apple-darwin14.tar.gz", "691e8244458c1de7aaa3ba766c0d18ca3b4cba1c5172016d7df626dc49fea571"),
    x86_64-linux-gnu => ("$bin_prefix/nettle.x86_64-linux-gnu.tar.gz", "fba5876b7ecf425ff05cc42896d7bd7c6ebfcaf276d01adfd9698e70cd4ddecf"),
    x86_64-w64-mingw32 => ("$bin_prefix/nettle.x86_64-w64-mingw32.tar.gz", "ccddd11750aa92957346c29282f8e2b649ad7459924230b0c91a3f74bea83a9b"),
)
if platform_key() in keys(download_info)
    # First, check to see if we're all satisfied
    if any(!satisfied(p; verbose=true) for p in [libnettle, nettlehash, nettlepc])
        # Download and install libnettle
        url, tarball_hash = download_info[platform_key()]
        install(url, tarball_hash; prefix=prefix, force=true, verbose=true)
    end
    @write_deps_file libnettle nettlehash
else
    error("Your platform $(Sys.MACHINE) is not recognized, we cannot install Nettle!")
end

