## Defines all HMAC functionality
## Pretty much everything in here learned from http://www.lysator.liu.se/~nisse/nettle/nettle.html#Keyed-hash-functions
## Also from reading the header files from libnettle source tree

import Base: show
export HMACState, update!, digest!, hexdigest!

# HMACState is the context that we keep around for HMAC hashing
type HMACState{T<:HashAlgorithm}
  outer::Array{UInt8,1}
  inner::Array{UInt8,1}
  state::Array{UInt8,1}
end

function show{T<:HashAlgorithm}(io::IO, ::HMACState{T})
  write(io, "$(string(T)) HMAC state")
end

function HMACState{T<:HashAlgorithm}(::Type{T}, key)
  outer = Array(UInt8,ctx_size(T))
  inner = Array(UInt8,ctx_size(T))
  state = Array(UInt8,ctx_size(T))

  ccall((:nettle_hmac_set_key,nettle),Void,(Ptr{Void},Ptr{Void},Ptr{Void},Ptr{Void},Csize_t,Ptr{UInt8}),outer,inner,state,hash_type(T),sizeof(key),key)
  HMACState{T}(outer,inner,state)
end

function update!{T<:HashAlgorithm}(state::HMACState{T},data)
  ccall((:nettle_hmac_update,nettle),Void,(Ptr{Void},Ptr{Void},Csize_t,Ptr{UInt8}),state.state,hash_type(T),sizeof(data),data)
  state
end

function digest!{T<:HashAlgorithm}(state::HMACState{T})
  dgst = Array(UInt8,output_size(T))
  ccall((:nettle_hmac_digest,nettle),Void,(Ptr{Void},Ptr{Void},Ptr{Void},Ptr{Void},Csize_t,Ptr{UInt8}),state.outer,state.inner,state.state,hash_type(T),sizeof(dgst),dgst)
  dgst
end
