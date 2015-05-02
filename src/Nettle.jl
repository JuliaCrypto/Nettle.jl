module Nettle

using Compat

const depfile = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
if isfile(depfile)
    include(depfile)
else
    error("Nettle not properly installed. Please run Pkg.build(\"Nettle\")")
end
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
    hash_init()
    cipher_init()
end

# Only manually call __init__() on old versions of Julia
if VERSION < v"0.3-"
    __init__()
end

# similar to Python's hmac.HMAC.hexdigest
hexdigest!(state::Union(HMACState,HashState)) = bytes2hex(digest!(state))
end
