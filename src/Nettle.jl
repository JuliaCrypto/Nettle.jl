module Nettle

# Load library
include( "../deps/deps.jl")

# Bring in Hashing functionality
include( "hash.jl" )

# Bring in HMAC functionality
include( "hmac.jl" )

digit(x::Integer) = '0'+x+39*(x>9)

# similar to Python's hmac.HMAC.hexdigest
function hexdigest!(state::Union(HMACState,HashState))
  d = digest!(state)
  n = length(d)
  h = Array(Uint8, 2*n)
  for i = 1:n
    x = d[i]
    h[2*i] = digit(x & 0xf)
    x >>= 4
    h[2*i-1] = digit(x & 0xf)
  end
  ASCIIString(h)
end

end # module
