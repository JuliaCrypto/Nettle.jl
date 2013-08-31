## Defines all hashing functionality
## As usual, check out http://www.lysator.liu.se/~nisse/nettle/nettle.html#Hash-functions

import Base: show
export HashState

# All Hash Algorithms derive from this abstract type
abstract HashAlgorithm


# This is the user-facing type that is used to actually hash stuff
type HashState{T<:HashAlgorithm}
  ctx::Array{Uint8,1}
end



# We're going to load in each nettle_hash struct individually, deriving
# HashAlgorithm types off of the names we find, and calculating the output
# and context size from the data members in the C structures
begin
  hash_idx = 1
  while( true )
    nh = unsafe_load(cglobal(("nettle_hashes",nettle),Ptr{Ptr{Void}}),hash_idx)
    if nh == C_NULL
      break
    end

    # Otherwise, we continue on to derive the information from this struct
    name_ptr = convert(Ptr{Uint8},unsafe_load(nh))
    name = symbol(uppercase(bytestring(name_ptr)))

    # Load in the Ptr{Uint32}'s
    ctx_size = unsafe_load(convert(Ptr{Uint32},nh),3)
    dgst_size = unsafe_load(convert(Ptr{Uint32},nh),4)
    block_size = unsafe_load(convert(Ptr{Uint32},nh),5)

    # Save the function pointers as well
    fptrs = nh + 24
    fptr_init = unsafe_load(fptrs,1)
    fptr_update = unsafe_load(fptrs,2)
    fptr_digest = unsafe_load(fptrs,3)
    

    # First, create the type itself
    @eval immutable $name <: HashAlgorithm; end

    # Next, record all the important information about this guy
    @eval output_size(::Type{$name}) = $(convert(Int,dgst_size))
    @eval ctx_size(::Type{$name}) = $(convert(Int,ctx_size))
    @eval hash_type(::Type{$name}) = $nh

    # Generate the init, update, and digest functions while we're at it!
    # Since we have the function pointers from nh, we'll use those
    @eval function HashState(::Type{$name})
      ctx = Array(Uint8, ctx_size($name))
      ccall($fptr_init,Void,(Ptr{Void},),ctx)
      HashState{$name}(ctx)
    end

    @eval function update!(state::HashState{$name},data)
      ccall($fptr_update,Void,(Ptr{Void},Csize_t,Ptr{Uint8}),state.ctx,sizeof(data),data)
    end

    @eval function digest!(state::HashState{$name})
      dgst = Array(Uint8,output_size($name))
      ccall($fptr_digest,Void,(Ptr{Void},Uint32,Ptr{Uint8}),state.ctx,sizeof(dgst),dgst)
      dgst
    end

    # Finally, export the type we just created
    eval(current_module(), Expr(:toplevel, Expr(:export, name)))

    hash_idx += 1
  end
end

function show{T<:HashAlgorithm}( io::IO, ::HashState{T} )
  write(io, "$(string(T)) Hash state")
end
