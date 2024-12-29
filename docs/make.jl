using Documenter
using Quarto

Quarto.render(joinpath(@__DIR__, "src"))

Documenter.deploydocs(repo = "https://github.com/cadojo/DocumenterQuarto.jl.git")
