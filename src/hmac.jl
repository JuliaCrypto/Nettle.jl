## Defines all HMAC functionality
## Pretty much everything in here learned from http://www.lysator.liu.se/~nisse/nettle/nettle.html#Keyed-hash-functions
## Also from reading the header files from libnettle source tree

import Base: show
export HMACState, update!, digest!, hexdigest!, calc_hmac

immutable HMACState
    hash_type::HashType
    outer::Array{UInt8,1}
    inner::Array{UInt8,1}
    state::Array{UInt8,1}
end

# Constructor for HMACState
function HMACState(name::AbstractString, key)
    hash_types = get_hash_types()
    name = uppercase(name)
    if !haskey(hash_types, name)
        throw(ArgumentError("Invalid hash type $name: call Nettle.get_hash_types() to see available list"))
    end

    # Construct HMACState object for this type and initialize using Nettle's init functions
    hash_type = hash_types[name]
    outer = Array(UInt8, hash_type.context_size)
    inner = Array(UInt8, hash_type.context_size)
    state = Array(UInt8, hash_type.context_size)
    ccall((:nettle_hmac_set_key,nettle), Void, (Ptr{Void},Ptr{Void},Ptr{Void},Ptr{Void},Csize_t,Ptr{UInt8}),
        outer, inner, state, hash_type.ptr, sizeof(key), key)
    return HMACState(hash_type, outer, inner, state)
end

function update!(state::HMACState, data)
    ccall((:nettle_hmac_update,nettle), Void, (Ptr{Void},Ptr{Void},Csize_t,Ptr{UInt8}), state.state,
        state.hash_type.ptr, sizeof(data), data)
    return state
end

function digest!(state::HMACState)
    digest = Array(UInt8,state.hash_type.digest_size)
    ccall((:nettle_hmac_digest,nettle), Void, (Ptr{Void},Ptr{Void},Ptr{Void},Ptr{Void}, Csize_t,
        Ptr{UInt8}), state.outer, state.inner, state.state, state.hash_type.ptr, sizeof(digest), digest)
    return digest
end

# Take a digest, and convert it to a printable hex representation
hexdigest!(state::HMACState) = bytes2hex(digest!(state))

# The one-shot function that makes this whole thing so easy
calc_hmac(name::AbstractString, key, data) = digest!(update!(HMACState(name, key), data))

show(io::IO, x::HMACState) = write(io, "$(x.hash_type.name) HMAC state")
