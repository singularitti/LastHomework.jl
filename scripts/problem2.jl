using Plots

using LastHomework.Lanczos
using LastHomework.QuantumMechanics

include("problem1.jl")

q = 0.001
H = Hamiltonian(A, ๐, q)

ntimes = 40

๐ = loop_lanczos(H, ntimes)
regionheatmap(myreshape(๐))
savefig("tex/plots/psi_heatmap.pdf")
surfaceplot(myreshape(๐))
savefig("tex/plots/psi_surface.pdf")
P = probability(๐)
regionheatmap(myreshape(P); right_margin=(3, :mm))
savefig("tex/plots/P_heatmap.pdf")
surfaceplot(myreshape(P); right_margin=(3, :mm))
savefig("tex/plots/P_surface.pdf")

print(probability(myreshape(๐), 1:N, 1:(N รท 2)))
