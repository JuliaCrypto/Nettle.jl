## Defines all HMAC functionality
## Pretty much everything in here learned from http://www.lysator.liu.se/~nisse/nettle/nettle.html#Keyed-hash-functions
## Also from reading the header files from libnettle source tree

import Base: show
export HMACAlgorithm, update!, digest!, hexdigest!, hmac

immutable NettleHMACState
    hash_type::NettleHashType
    outer::Array{UInt8,1}
    inner::Array{UInt8,1}
    state::Array{UInt8,1}
end

# Constructor for NettleHMACState
function HMACAlgorithm(name::AbstractString, key)
    hash_types = get_hash_types()
    name = uppercase(name)
    if !haskey(hash_types, name)
        ArgumentError("Invalid hash type $name: call Nettle.get_hash_types() to see available list")
    end

    # Construct HMACAlgorithm object for this type and initialize using Nettle's init functions
    hash_type = hash_types[name]
    outer = Array(UInt8, hash_type.context_size)
    inner = Array(UInt8, hash_type.context_size)
    state = Array(UInt8, hash_type.context_size)
    ccall((:nettle_hmac_set_key,nettle), Void, (Ptr{Void},Ptr{Void},Ptr{Void},Ptr{Void},Csize_t,Ptr{UInt8}),
        outer, inner, state, hash_type.ptr, sizeof(key), key)
    return NettleHMACState(hash_type, outer, inner, state)
end

function update!(state::NettleHMACState, data)
    ccall((:nettle_hmac_update,nettle), Void, (Ptr{Void},Ptr{Void},Csize_t,Ptr{UInt8}), state.state,
        state.hash_type.ptr, sizeof(data), data)
    return state
end

function digest!(state::NettleHMACState)
    digest = Array(UInt8,state.hash_type.digest_size)
    ccall((:nettle_hmac_digest,nettle), Void, (Ptr{Void},Ptr{Void},Ptr{Void},Ptr{Void}, Csize_t,
        Ptr{UInt8}), state.outer, state.inner, state.state, state.hash_type.ptr, sizeof(digest), digest)
    return digest
end

# Take a digest, and convert it to a printable hex representation
hexdigest!(state::NettleHMACState) = bytes2hex(digest!(state))

# The one-shot function that makes this whole thing so easy
function hmac(name::AbstractString, key, data)
    return digest!(update!(HMACAlgorithm(name, key), data))
end

show(io::IO, x::NettleHashState) = write(io, "Nettle $(x.hash_type.name) HMAC state")
