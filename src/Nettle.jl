module Nettle

using BinDeps
@BinDeps.load_dependencies [:nettle]

# Bring in Hashing functionality
include( "hash.jl" )

# Bring in HMAC functionality
include( "hmac.jl" )


# similar to Python's hmac.HMAC.hexdigest
function hexdigest!(state::Union(HMACState,HashState))
  d = digest!(state)
  n = length(d)
  h = Array(Uint8, 2*n)
  for i = 1:n
    x = d[i]
    h[2*i] = Base.digit(x & 0xf)
    x >>= 4
    h[2*i-1] = Base.digit(x & 0xf)
  end
  ASCIIString(h)
end

end # module
