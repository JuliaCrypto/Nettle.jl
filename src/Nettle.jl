module Nettle

include( "../deps/deps.jl")
include( "hash.jl" )
include( "hmac.jl" )

# similar to Python's hmac.HMAC.hexdigest
hexdigest!(state::Union(HMACState,HashState)) = bytes2hex(digest!(state))

end
