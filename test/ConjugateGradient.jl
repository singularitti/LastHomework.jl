module ConjugateGradient

using LastHomework: solve, isconverged, eachstep
using LinearAlgebra: norm
using Test: @testset, @test

# Example is from https://en.wikipedia.org/wiki/Conjugate_gradient_method#Numerical_example
@testset "Test Wikipedia example" begin
    A = [
        4 1
        1 3
    ]
    𝐛 = [1, 2]
    𝐱₀ = [2, 1]
    𝐱, ch = solve(A, 𝐛, 𝐱₀, 1e-24)
    @test 𝐱 ≈ [1 / 11, 7 / 11]  # Compare with the exact solution
    @test norm(A * 𝐱 - 𝐛) / norm(𝐛) ≤ 1e-12
    @test isconverged(ch) == true
    steps = eachstep(ch)
    @test steps[0].r == steps[0].p == -[8, 3]
    @test steps[0].alpha == 73 / 331
    @test steps[0].beta ≈ 0.008771369374138607
    @test steps[1].x == [2, 1] - 73 / 331 * [8, 3]
    @test steps[1].r == -[8, 3] + 73 / 331 * [4 1; 1 3] * [8, 3]
    @test steps[1].p ≈ [-0.3511377223647101, 0.7229306048685207]
    @test steps[1].alpha ≈ 0.4122042341220423
    @test steps[2].x ≈ [0.09090909090909094, 0.6363636363636365]
end

# Example is from https://optimization.mccormick.northwestern.edu/index.php/Conjugate_gradient_methods#Numerical_Example_of_the_method
@testset "Test Erik Zuehlke's example" begin
    A = [
        5 1
        1 2
    ]
    𝐛 = [2, 2]
    𝐱₀ = [1, 2]
    𝐱, ch = solve(A, 𝐛, 𝐱₀, 1e-24)
    @test 𝐱 ≈ [0.2222222222222221, 0.8888888888888891]  # Compare with other's result
    @test norm(A * 𝐱 - 𝐛) / norm(𝐛) ≤ 1e-12
    @test isconverged(ch) == true
    steps = eachstep(ch)
    @test steps[0].r == steps[0].p == -[5, 3]
    @test steps[0].alpha == 34 / 173
    @test steps[0].beta ≈ 0.028099836279194094  # The example's result is wrong
    @test steps[1].x == [1, 2] - 34 / 173 * [5, 3]
    @test steps[1].r == -[5, 3] + 34 / 173 * [5 1; 1 2] * [5, 3]
    @test steps[1].p ≈ [0.3623909920144345, -0.9224497978549232]
end

end
