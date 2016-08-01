VERSION >= v"0.4.0-dev+6521" && __precompile__()
module Nettle
using Compat
import Compat.String

# Load libnettle from BinDeps
const depfile = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
if isfile(depfile)
    include(depfile)
else
    error("libnettle not properly installed. Please run Pkg.build(\"Nettle\")")
end

include( "hash_common.jl" )
include( "hash.jl" )
include( "hmac.jl" )
include( "cipher.jl" )

function get_libnettle_version()
    # Current version (3.1.1) of nettle doesn't provide a runtime API to query
    # the version. Using the existance of a symbol added in 3.0 to determine
    # which version is loaded at runtime. See #46 and
    # http://upstream-tracker.org/versions/nettle.html
    hdl = @compat Libdl.dlopen_e(nettle)
    @compat(Libdl.dlsym_e(hdl, :nettle_aes192_invert_key)) == C_NULL ? 2 : 3
end

function __init__()
    global const nettle_major_version = get_libnettle_version()
end

if VERSION >= v"0.4.0-dev+6521"
    include("precompile.jl")
    _precompile_()
end

end # module
