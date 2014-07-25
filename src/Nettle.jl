module Nettle

include( "../deps/deps.jl")
include( "hash.jl" )
include( "hmac.jl" )

hash(state::Union(HMACState,HashState),string) = digest!(update!(state, string))

# similar to Python's hmac.HMAC.hexdigest
hexdigest!(state::Union(HMACState,HashState)) = bytes2hex(digest!(state))

end
