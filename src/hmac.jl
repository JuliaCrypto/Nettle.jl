## Defines all HMAC functionality
## Pretty much everything in here learned from http://www.lysator.liu.se/~nisse/nettle/nettle.html#Keyed-hash-functions
## Also from reading the header files from libnettle source tree

import Base: show
export HMACState, update!, digest, digest!, hexdigest!, hexdigest

immutable HMACState
    hash_type::HashType
    outer::Vector{UInt8}
    inner::Vector{UInt8}
    state::Vector{UInt8}
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
    outer = Vector{UInt8}(hash_type.context_size)
    inner = Vector{UInt8}(hash_type.context_size)
    state = Vector{UInt8}(hash_type.context_size)
    ccall((:nettle_hmac_set_key,libnettle), Void, (Ptr{Void},Ptr{Void},Ptr{Void},Ptr{Void},Csize_t,Ptr{UInt8}),
        outer, inner, state, hash_type.ptr, sizeof(key), key)
    return HMACState(hash_type, outer, inner, state)
end

function update!(state::HMACState, data)
    ccall((:nettle_hmac_update,libnettle), Void, (Ptr{Void},Ptr{Void},Csize_t,Ptr{UInt8}), state.state,
        state.hash_type.ptr, sizeof(data), data)
    return state
end

function digest!(state::HMACState)
    digest = Vector{UInt8}(state.hash_type.digest_size)
    ccall((:nettle_hmac_digest,libnettle), Void, (Ptr{Void},Ptr{Void},Ptr{Void},Ptr{Void}, Csize_t,
        Ptr{UInt8}), state.outer, state.inner, state.state, state.hash_type.ptr, sizeof(digest), digest)
    return digest
end

# Take a digest, and convert it to a printable hex representation
hexdigest!(state::HMACState) = bytes2hex(digest!(state))

# The one-shot functions that makes this whole thing so easy
digest(hmac_name::AbstractString, key, data) = digest!(update!(HMACState(hmac_name, key), data))
hexdigest(hmac_name::AbstractString, key, data) = hexdigest!(update!(HMACState(hmac_name, key), data))

show(io::IO, x::HMACState) = write(io, "$(x.hash_type.name) HMAC state")
