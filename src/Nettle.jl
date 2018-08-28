module Nettle

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

function __init__()
    # Always check your dependencies that live in `deps.jl`
    check_deps()
end

# SnoopCompile acceleration
include("precompile.jl")
_precompile_()

end # module
