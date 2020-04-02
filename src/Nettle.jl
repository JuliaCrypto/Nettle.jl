module Nettle
using Nettle_jll, Libdl

include("hash_common.jl")
include("hash.jl")
include("hmac.jl")
include("cipher.jl")

# SnoopCompile acceleration
include("precompile.jl")
_precompile_()

end # module
