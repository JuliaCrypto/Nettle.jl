module Nettle

if isfile(joinpath(Pkg.dir("Nettle"),"deps","deps.jl"))
   include("../deps/deps.jl")
else
    error("Nettle not properly installed. Please run Pkg.build(\"Nettle\")")
end
include( "hash.jl" )
include( "hmac.jl" )

# similar to Python's hmac.HMAC.hexdigest
hexdigest!(state::Union(HMACState,HashState)) = bytes2hex(digest!(state))

end
