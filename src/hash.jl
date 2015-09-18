## Defines all hashing functionality
## As usual, check out http://www.lysator.liu.se/~nisse/nettle/nettle.html#Hash-functions

import Base: show
export HashAlgorithm, update!, digest!, hexdigest!, hash!

immutable NettleHashState
    hash_type::NettleHashType
    state::Array{UInt8,1}
end

# Constructor for NettleHashState
function HashAlgorithm(name::AbstractString)
    hash_types = get_hash_types()
    name = uppercase(name)
    if !haskey(hash_types, name)
        ArgumentError("Invalid hash type $name: call Nettle.get_hash_types() to see available list")
    end

    # Construct HashAlgorithm object for this type and initialize using Nettle's init functions
    hash_type = hash_types[name]
    state = Array(UInt8, hash_type.context_size)
    ccall(hash_type.init, Void, (Ptr{Void},), state)
    return NettleHashState(hash_type, state)
end

# Update hash state with new data
function update!(state::NettleHashState, data)
    ccall(state.hash_type.update, Void, (Ptr{Void},Csize_t,Ptr{UInt8}), state.state, sizeof(data), pointer(data))
    return state
end

# Spit out a digest of the current hash state and reset it
function digest!(state::NettleHashState)
    digest = Array(UInt8, state.hash_type.digest_size)
    ccall(state.hash_type.digest, Void, (Ptr{Void},UInt32,Ptr{UInt8}), state.state, sizeof(digest), pointer(digest))
    return digest
end

# Take a digest, and convert it to a printable hex representation
hexdigest!(state::NettleHashState) = bytes2hex(digest!(state))

# The one-shot function that makes this whole thing so easy.  We abuse ! notation to avoid
# clashing with the very likely case of a user naming a variable "hash".
hash!(name::AbstractString, data) = digest!(update!(HashAlgorithm(name), data))

# Custom show overrides make this package have a little more pizzaz!
function show(io::IO, x::NettleHashType)
    write(io, "Nettle $(x.name) Hash\n")
    write(io, "  Context size: $(x.context_size) bits\n")
    write(io, "  Digest size: $(x.digest_size) bits\n")
    write(io, "  Block size: $(x.block_size) bits")
end
show(io::IO, x::NettleHashState) = write(io, "Nettle $(x.hash_type.name) Hash state")

