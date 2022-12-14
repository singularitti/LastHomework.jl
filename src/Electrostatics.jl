module Electrostatics

using LinearAlgebra: norm, â

using ..LastHomework:
    DiscreteLaplacian, Boundary, InternalSquare, PointCharges, validate, setvalues!
using ..ConjugateGradient: Step, setconverged!, log!

import ..ConjugateGradient: solve!

function solve!(
    logger,
    A::DiscreteLaplacian,
    ğ,
    ğ±â;
    atol=eps(),
    maxiter=2000,
    charge=-20,
    bc=0,
    ext_pot=5,
)
    N = Int(sqrt(length(ğ)))
    BOUNDARY = Boundary((N, N), bc)
    SQUARE = InternalSquare((N, N), ext_pot)
    SQUARE_RESIDUAL = InternalSquare((N, N), 0)
    setvalues!(ğ±â, BOUNDARY)
    setvalues!(ğ±â, SQUARE)
    setvalues!(ğ, PointCharges((N, N), charge))
    ğ±â = copy(ğ±â)
    ğ«â = ğ - A * ğ±â  # Initial residual, ğ«â
    ğ©â = ğ«â  # Initial momentum, ğ©â, notice that if you cahnge ğ©â, 
    for n in 0:maxiter
        if norm(ğ«â) < atol
            setconverged!(logger)
            break
        end
        setvalues!(ğ©â, BOUNDARY)
        setvalues!(ğ©â, SQUARE_RESIDUAL)  # Set ğ©â and ğ«â to zero in the square
        Ağ©â = A * ğ©â  # Avoid running it multiple times
        Î±â = ğ«â â ğ«â / (ğ©â â Ağ©â)  # `â` means dot product between two vectors
        ğ±âââ = ğ±â + Î±â * ğ©â
        Î±âAğ©â = Î±â * Ağ©â
        setvalues!(Î±âAğ©â, BOUNDARY)
        setvalues!(Î±âAğ©â, SQUARE_RESIDUAL)  # Set Î±âAğ©â to 0 in the square
        ğ«âââ = ğ«â - Î±âAğ©â
        Î²â = ğ«âââ â ğ«âââ / (ğ«â â ğ«â)
        ğ©âââ = ğ«âââ + Î²â * ğ©â
        log!(logger, Step(n, Î±â, Î²â, ğ±â, ğ«â, ğ©â))
        ğ±â, ğ«â, ğ©â = ğ±âââ, ğ«âââ, ğ©âââ  # Prepare for a new iteration
        # validate(ğ«â, SQUARE_RESIDUAL)
        # validate(ğ±â, SQUARE)  # Check if ğ±â is 5 in the square
    end
    return ğ±â
end

end
