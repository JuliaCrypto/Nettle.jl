module Nettle

const depfile = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
if isfile(depfile)
    include(depfile)
else
    error("Nettle not properly installed. Please run Pkg.build(\"Nettle\")")
end
include( "hash.jl" )
include( "hmac.jl" )

# similar to Python's hmac.HMAC.hexdigest
hexdigest!(state::Union(HMACState,HashState)) = bytes2hex(digest!(state))

end
