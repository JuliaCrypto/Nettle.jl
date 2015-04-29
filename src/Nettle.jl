module Nettle

const depfile = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
if isfile(depfile)
    include(depfile)
else
    error("Nettle not properly installed. Please run Pkg.build(\"Nettle\")")
end
include( "hash.jl" )
include( "hmac.jl" )
include( "cipher.jl" )

function __init__()
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
