## Defines all hashing functionality
## As usual, check out http://www.lysator.liu.se/~nisse/nettle/nettle.html#Hash-functions

import Base: show
export HashState, HashAlgorithm, HashAlgorithms

# All Hash Algorithms derive from this abstract type
abstract HashAlgorithm

# This is our rather poorly named list of HashAlgorithm types
HashAlgorithms = DataType[]


# This is the user-facing type that is used to actually hash stuff
type HashState{T<:HashAlgorithm}
    ctx::Array{Uint8,1}
end

# This is a mirror of the nettle-meta.h:nettle_hash struct
immutable NettleHash
    name::Ptr{Uint8}
    context_size::Cuint
    digest_size::Cuint
    block_size::Cuint
    init::Ptr{Void}     # nettle_hash_init_func
    update::Ptr{Void}   # nettle_hash_update_func
    digest::Ptr{Void}   # nettle_hash_digest_func
end


# We're going to load in each nettle_hash struct individually, deriving
# HashAlgorithm types off of the names we find, and calculating the output
# and context size from the data members in the C structures
function hash_init()
    hash_idx = 1
    while( true )
    nhptr = unsafe_load(cglobal(("nettle_hashes",nettle),Ptr{Ptr{Void}}),hash_idx)
    if nhptr == C_NULL
        break
    end
    nh = unsafe_load(convert(Ptr{NettleHash}, nhptr))

    # Otherwise, we continue on to derive the information from this struct
    name = symbol(uppercase(bytestring(nh.name)))

    # Load in the Ptr{Uint32}'s
    ctx_size = nh.context_size
    dgst_size = nh.digest_size
    block_size = nh.block_size

    # Save the function pointers as well
    fptr_init = nh.init
    fptr_update = nh.update
    fptr_digest = nh.digest

    # First, create the type itself
    @eval immutable $name <: HashAlgorithm; end

    # Next, record all the important information about this hash algorithm
    @eval output_size(::Type{$name}) = $(convert(Int,dgst_size))
    @eval ctx_size(::Type{$name}) = $(convert(Int,ctx_size))
    @eval hash_type(::Type{$name}) = $nhptr

    # Generate the init, update, and digest functions while we're at it!
    # Since we have the function pointers from nh, we'll use those
    @eval function HashState(::Type{$name})
        ctx = Array(Uint8, ctx_size($name))
        ccall($fptr_init,Void,(Ptr{Void},),ctx)
        HashState{$name}(ctx)
    end

    @eval function update!(state::HashState{$name},data)
        ccall($fptr_update,Void,(Ptr{Void},Csize_t,Ptr{Uint8}),state.ctx,sizeof(data),pointer(data))
        state
    end

    @eval function digest!(state::HashState{$name})
        dgst = Array(Uint8,output_size($name))
        ccall($fptr_digest,Void,(Ptr{Void},Uint32,Ptr{Uint8}),state.ctx,sizeof(dgst),pointer(dgst))
        dgst
    end

    # Generate e.g. sha256_hash(string) and sha256_hmac(string)
    name_hash = symbol("$(bytestring(nh.name))_hash")
    @eval $name_hash(string) = digest!(update!(HashState($name), string))

    name_hmac = symbol("$(bytestring(nh.name))_hmac")
    @eval $name_hmac(key, string) = digest!(update!(HMACState($name, key), string))

    # Add this type into the HashAlgorithms group
    @eval push!(HashAlgorithms, $name)

    # Finally, export the type we just created
    for sym in [name, name_hash, name_hmac]
        eval(Expr(:export, sym))
    end

    hash_idx += 1
    end
end

function show{T<:HashAlgorithm}( io::IO, ::HashState{T} )
    write(io, "$(string(T)) Hash state")
end
