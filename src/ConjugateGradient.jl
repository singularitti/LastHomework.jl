module ConjugateGradient

using LinearAlgebra: norm, â
using OffsetArrays: OffsetVector, Origin

export Logger, solve, solve!, isconverged, eachstep

struct Step
    n::UInt64
    alpha::Float64
    beta::Float64
    x::Vector{Float64}
    r::Vector{Float64}
    p::Vector{Float64}
end

abstract type AbstractLogger end
mutable struct EmptyLogger <: AbstractLogger
    isconverged::Bool
end
EmptyLogger() = EmptyLogger(false)
mutable struct Logger <: AbstractLogger
    isconverged::Bool
    data::OffsetVector{Step}
end
Logger() = Logger(false, OffsetVector([], Origin(0)))

function solve!(logger, A, ğ, ğ±â=zeros(length(ğ)); atol=eps(), maxiter=2000)
    ğ±â = ğ±â
    ğ«â = ğ - A * ğ±â  # Initial residual, ğ«â
    ğ©â = ğ«â  # Initial momentum, ğ©â
    for n in 0:maxiter
        if norm(ğ«â) < atol
            setconverged!(logger)
            break
        end
        Ağ©â = A * ğ©â  # Avoid duplicated computation
        Î±â = ğ«â â ğ«â / (ğ©â â Ağ©â)  # `â` means dot product between two vectors
        ğ±âââ = ğ±â + Î±â * ğ©â
        ğ«âââ = ğ«â - Î±â * Ağ©â
        Î²â = ğ«âââ â ğ«âââ / (ğ«â â ğ«â)
        ğ©âââ = ğ«âââ + Î²â * ğ©â
        log!(logger, Step(n, Î±â, Î²â, ğ±â, ğ«â, ğ©â))
        ğ±â, ğ«â, ğ©â = ğ±âââ, ğ«âââ, ğ©âââ  # Prepare for a new iteration
    end
    return ğ±â
end
solve(A, ğ, ğ±â=zeros(length(ğ)); kwargs...) = solve!(EmptyLogger(), A, ğ, ğ±â; kwargs...)

log!(::EmptyLogger, args...) = nothing
log!(logger::Logger, step) = push!(logger.data, step)

function setconverged!(logger::AbstractLogger)
    logger.isconverged = true
    return logger
end

isconverged(ch::Logger) = ch.isconverged

struct EachStep
    history::Logger
end

eachstep(logger::Logger) = EachStep(logger)

Base.iterate(iter::EachStep) = iterate(iter.history.data)
Base.iterate(iter::EachStep, state) = iterate(iter.history.data, state)

Base.eltype(::EachStep) = Step

Base.length(iter::EachStep) = length(iter.history.data)

Base.size(iter::EachStep, dim...) = size(iter.history.data, dim...)

Base.getindex(iter::EachStep, i) = getindex(iter.history.data, i)

Base.firstindex(iter::EachStep) = firstindex(iter.history.data)

Base.lastindex(iter::EachStep) = lastindex(iter.history.data)

function Base.show(io::IO, step::Step)
    if get(io, :compact, false) || get(io, :typeinfo, nothing) == typeof(step)
        Base.show_default(IOContext(io, :limit => true), step)  # From https://github.com/mauro3/Parameters.jl/blob/ecbf8df/src/Parameters.jl#L556
    else
        println(io, summary(step))
        println(io, " n = ", Int(step.n))
        println(io, " Î± = ", step.alpha)
        println(io, " Î² = ", step.beta)
        println(io, " ğ± = ", step.x)
        println(io, " ğ« = ", step.r)
        println(io, " ğ© = ", step.p)
    end
end

end
