__precompile__()
module Nettle
using Compat
import Compat.String

# Load libnettle from our deps.jl
const depsjl_path = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
if !isfile(depsjl_path)
    error("Nettle not installed properly, run Pkg.build(\"Nettle\"), restart Julia and try again")
end
include(depsjl_path)

include("hash_common.jl")
include("hash.jl")
include("hmac.jl")
include("cipher.jl")

function get_libnettle_version()
    global libnettle
    # Current version (3.1.1) of nettle doesn't provide a runtime API to query
    # the version. Using the existance of a symbol added in 3.0 to determine
    # which version is loaded at runtime. See #46 and
    # https://abi-laboratory.pro/tracker/timeline/nettle/
    hdl = @compat Libdl.dlopen_e(libnettle)
    @compat(Libdl.dlsym_e(hdl, :nettle_aes192_invert_key)) == C_NULL ? 2 : 3
end

function __init__()
    # Always check your dependencies that live in `deps.jl`
    check_deps()
    
    # Get the current nettle major version that's loaded in
    global const nettle_major_version = get_libnettle_version()
end

# SnoopCompile acceleration
include("precompile.jl")
_precompile_()

end # module
