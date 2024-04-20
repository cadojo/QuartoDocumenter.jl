# Preface {.unnumbered}

This is a Quarto book.

To learn more about Quarto books visit <https://quarto.org/docs/books>.

::: {.cell execution_count=1}
``` {.julia .cell-code}
using QuartoDocumenter, AstrodynamicalModels
QuartoDocumenter.autodoc(AstrodynamicalModels)
```

::: {.cell-output .cell-output-stderr}
```
Precompiling QuartoDocumenter
  ✓ QuartoDocumenter
  1 dependency successfully precompiled in 1 seconds. 27 already precompiled.
```
:::

::: {.cell-output .cell-output-display .cell-output-markdown execution_count=2}
:::{.callout appearance="simple"}

Provides astrodynamical models as `AstrodynamicalModels.ODESystems`. Check out the `ModelingToolkit` docs to learn how to use these systems for orbit propagation with `DifferentialEquations`, or see `GeneralAstrodynamics` for some convenient orbit propagation wrappers.

#### Extended help

##### License

MIT License

Copyright (c) 2023 Joseph D Carpinelli

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

##### Exports

  * [`AttitudeFunction`](@ref)
  * [`AttitudeParameters`](@ref)
  * [`AttitudeState`](@ref)
  * [`AttitudeSystem`](@ref)
  * [`CR3BFunction`](@ref)
  * [`CR3BOrbit`](@ref)
  * [`CR3BParameters`](@ref)
  * [`CR3BState`](@ref)
  * [`CR3BSystem`](@ref)
  * [`CartesianOrbit`](@ref)
  * [`CartesianState`](@ref)
  * [`KeplerianOrbit`](@ref)
  * [`KeplerianParameters`](@ref)
  * [`KeplerianState`](@ref)
  * [`NBFunction`](@ref)
  * [`NBSystem`](@ref)
  * [`Orbit`](@ref)
  * [`OrbitalElements`](@ref)
  * [`PlanarEntryFunction`](@ref)
  * [`PlanarEntryParameters`](@ref)
  * [`PlanarEntryState`](@ref)
  * [`PlanarEntrySystem`](@ref)
  * [`R2BFunction`](@ref)
  * [`R2BOrbit`](@ref)
  * [`R2BParameters`](@ref)
  * [`R2BState`](@ref)
  * [`R2BSystem`](@ref)
  * [`dynamics`](@ref)
  * [`parameters`](@ref)
  * [`state`](@ref)
  * [`system`](@ref)

##### Imports

  * `Base`
  * `Core`
  * `DocStringExtensions`
  * `LinearAlgebra`
  * `Memoize`
  * `ModelingToolkit`
  * `SciMLBase`
  * `StaticArrays`
  * `Symbolics`

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
AttitudeFunction(; stm, name, kwargs...)

```

Returns an `ODEFunction` for spacecraft attitude dynamics.

#### Extended Help

###### Usage

The `stm` and `name` keyword arguments are passed to `Attitude`. All other keyword arguments are passed directly to `SciMLBase.ODEFunction`.

```julia
f = AttitudeFunction()
let u = randn(7), p = randn(15), t = NaN # time invariant
    f(u, p, t)
end
```

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
struct AttitudeParameters{F} <: AstrodynamicalModels.AstrodynamicalParameters{F, 15}
```

A parameter vector for attitude dynamics.

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
mutable struct AttitudeState{F} <: AstrodynamicalModels.AstrodynamicalState{F, 7}
```

A mutable state vector for attitude dynamics.

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
AttitudeSystem(; stm, name, defaults, kwargs...)

```

A `ModelingToolkit.ODESystem` for atmospheric entry. Currently, only exponential atmosphere models are provided! The output model is cached with `Memoize.jl`. Planet-specific parameters default to Earth values.

The order of the states follows: `[q₁, q₂, q₃, q₄, ω₁, ω₂, ω₃]`.

The order of the parameters follows: `[]`

#### Extended Help

This model describes how an object moves through an exponential atmosphere, above a spherical planet.

##### States

1. `q`: scalar-last attitude quaternion
2. `ω`: body rates (radians per second)

##### Parameters

1. `J`: inertial matrix
2. `L`: lever arm where input torque is applied
3. `f`: torques on the vehicle body (Newton-meters)

###### Usage

```julia
model = Attitude()
```

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
CR3BFunction(; stm, name, kwargs...)

```

Returns an `ODEFunction` for CR3B dynamics.

The order of the states follows: `[μ]`.

The order of the parameters follows: `[μ]`.

#### Extended Help

###### Usage

The `stm`, and `name` keyword arguments are passed to `CR3B`. All other keyword arguments are passed directly to `SciMLBase.ODEFunction`.

```julia
f = CR3BFunction(; stm=false, jac=true)
let u = randn(6), p = randn(1), t = 0
    f(u, p, t)
end
```

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
struct Orbit{var"#s25"<:CartesianState, var"#s24"<:CR3BParameters} <: AstrodynamicalModels.AstrodynamicalOrbit{var"#s25"<:CartesianState, var"#s24"<:CR3BParameters}
```

An `Orbit` which exists within CR3BP dynamics.

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
struct CR3BParameters{F} <: AstrodynamicalModels.AstrodynamicalParameters{F, 1}
```

A paremeter vector for CR3BP dynamics.

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
mutable struct CartesianState{F} <: AstrodynamicalModels.AstrodynamicalState{F, 6}
```

CartesianState

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
CR3BSystem(; stm, name, defaults, kwargs...)

```

A `ModelingToolkit.ODESystem` for the Circular Restricted Three-body Problem.

The order of the states follows: `[x, y, z, ẋ, ẏ, ż]`.

The order of the parameters follows: `[μ]`.

#### Extended Help

The Circular Restricted Three-body Problem is a simplified dynamical model describing one small body (spacecraft, etc.) and two celestial bodies moving in a circle about their common center of mass. This may seem like an arbitrary simplification, but this assumption holds reasonably well for the Earth-Moon, Sun-Earth, and many other systems in our solar system.

###### Usage

```julia
model = CR3BSystem(; stm=true)
```

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
struct Orbit{var"#s25"<:CartesianState, P<:(AbstractVector)} <: AstrodynamicalModels.AstrodynamicalOrbit{var"#s25"<:CartesianState, P<:(AbstractVector)}
```

An `Orbit` which exists within R2BP dynamics.

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
mutable struct CartesianState{F} <: AstrodynamicalModels.AstrodynamicalState{F, 6}
```

A mutable vector, with labels, for 6DOF Cartesian states.

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
struct Orbit{var"#s25"<:OrbitalElements, var"#s24"<:KeplerianParameters} <: AstrodynamicalModels.AstrodynamicalOrbit{var"#s25"<:OrbitalElements, var"#s24"<:KeplerianParameters}
```

An `Orbit` which exists within Keplerian dynamics.

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
struct KeplerianParameters{F} <: AstrodynamicalModels.AstrodynamicalParameters{F, 1}
```

A parameter vector for Keplerian dynamics.

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
mutable struct OrbitalElements{F} <: AstrodynamicalModels.AstrodynamicalState{F, 6}
```

OrbitalElements

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
NBFunction(N; stm, name, kwargs...)

```

Returns an `ODEFunction` for NBP dynamics. The order of states and parameters in the `ODEFunction` arguments are equivalent to the order of states and parameters for the system produced with `NBP(N)`. As a general rule, the order of the states follows: `[x₁, y₁, z₁, ..., xₙ, yₙ, zₙ, ẋ₁, ẏ₁, ż₁, ..., ẋₙ, ẏₙ, żₙ]`.

:::{.callout-note title="Note"}

Unlike `R2BP` and `CR3BP`, `jac` is set to `false` by default. The number of states for `NBP` systems can be very large for relatively small numbers of bodies (`N`). Enabling `jac=true` by default would cause unnecessarily long waiting times for this @memoize function to return for `N ≥ 3` or so. If `N=2` and `stm=true`, setting `jac=true` could still result in several minutes of calculations, depending on the computer you're using.

:::

:::{.callout-warning title="Warning"}

Be careful about specifying `stm=true` for systems with `N ≥ 3`! If state transition matrix dynamics are enabled, you can calculate the total number of system states with `N*6 + (N*6)^2`. Note that this increases exponentially as `N` grows! For `N == 6`, unless you're using parallelization, your computer may run for several hours.

:::

#### Extended Help

###### Usage

The `stm`, and `name` keyword arguments are passed to `NBP`. All other keyword arguments are passed directly to `SciMLBase.ODEFunction`.

```julia
f = NBFunction(3; stm=false, name=:NBP, jac=false, sparse=false)
let u = randn(3*6), p = randn(1 + 3), t = 0
    f(u, p, t)
end
```

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
NBSystem(N; stm, name, defaults, kwargs...)

```

A `ModelingToolkit.ODESystem` for the Newtonian N-body Problem.

The order of the states follows: `[x₁, y₁, z₁, ..., xₙ, yₙ, zₙ, ẋ₁, ẏ₁, ż₁, ..., ẋₙ, ẏₙ, żₙ]`.

The order of the parameters follows: `[G, m₁, m₂, ..., mₙ]`.

:::{.callout-warning title="Warning"}

Be careful about specifying `stm=true` for systems with `N ≥ 3`! If state transition matrix dynamics are enabled, you can calculate the total number of system states with `N*6 + (N*6)^2`. Note that this increases exponentially as `N` grows! For `N == 6`, unless you're using parallelization, your computer may run for several hours.

:::

#### Extended Help

The N-body problem is a model which describes how `N` bodies will move with respect to a common origin. This problem typically involves many bodies which act due to one force: electromagentism, gravity, etc. This model applies most closely to many celestial bodies moving due to gravity. That's about right for a model in a package called `AstrodynamicalModels`!

###### Usage

```julia
# One model for ALL the planets in our solar system 😎
model = NBSystem(9)
```

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
struct Orbit{U<:(AbstractVector), P<:(AbstractVector)} <: AstrodynamicalModels.AstrodynamicalOrbit{U<:(AbstractVector), P<:(AbstractVector)}
```

A full representation of an orbit, including a numerical state, and the parameters of the system.

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
mutable struct OrbitalElements{F} <: AstrodynamicalModels.AstrodynamicalState{F, 6}
```

A mutable vector, with labels, for 6DOF Keplerian states.

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
PlanarEntryFunction(; name, kwargs...)

```

Returns an `ODEFunction` for Planar Entry dynamics. Results are cached with `Memoize.jl`.

The order of the states follows: `[γ, v, r, θ]`.

The order of the parameters follows: `[R, P, H, m, A, C, μ]`

#### Extended Help

###### Usage

The `name` keyword argument is ]passed to `PlanarEntry`. All other keyword arguments are passed directly to `SciMLBase.ODEFunction`.

```julia
f = PlanarEntryFunction()
let u = randn(4), p = randn(7), t = NaN # time invariant
    f(u, p, t)
end
```

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
struct PlanarEntryParameters{F} <: AstrodynamicalModels.AstrodynamicalParameters{F, 7}
```

A parameter vector for planar entry dynamics.

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
mutable struct PlanarEntryState{F} <: AstrodynamicalModels.AstrodynamicalState{F, 4}
```

A state vector for planar entry dynamics.

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
PlanarEntrySystem(; name, defaults, kwargs...)

```

A `ModelingToolkit.ODESystem` for atmospheric entry. Currently, only exponential atmosphere models are provided! The output model is cached with `Memoize.jl`. Planet-specific parameters default to Earth values.

The order of the states follows: `[γ, v, r, θ]`.

The order of the parameters follows: `[R, P, H, m, A, C, μ]`

#### Extended Help

This model describes how an object moves through an exponential atmosphere, above a spherical planet.

###### Usage

```julia
model = PlanarEntrySystem()
```

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
R2BFunction(; stm, name, kwargs...)

```

Returns an `ODEFunction` for R2B dynamics.

The order of the states follows: `[x, y, z, ẋ, ẏ, ż]`.

The order of the parameters follows: `[μ]`.

#### Extended Help

###### Usage

The `stm`, and `name` keyword arguments are passed to `R2B`. All other keyword arguments are passed directly to `SciMLBase.ODEFunction`.

```julia
f = R2BFunction(; stm=false, name=:R2B, jac=true)
let u = randn(6), p = randn(1), t = 0
    f(u, p, t)
end
```

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
struct Orbit{var"#s25"<:CartesianState, var"#s24"<:R2BParameters} <: AstrodynamicalModels.AstrodynamicalOrbit{var"#s25"<:CartesianState, var"#s24"<:R2BParameters}
```

An `Orbit` which exists within R2BP dynamics.

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
struct R2BParameters{F} <: AstrodynamicalModels.AstrodynamicalParameters{F, 1}
```

A parameter vector for R2BP dynamics.

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
mutable struct CartesianState{F} <: AstrodynamicalModels.AstrodynamicalState{F, 6}
```

CartesianState

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
R2BSystem(; stm, name, defaults, kwargs...)

```

A `ModelingToolkit.ODESystem` for the Restricted Two-body Problem.

The order of the states follows: `[x, y, z, ẋ, ẏ, ż]`.

The order of the parameters follows: `[μ]`.

#### Extended Help

The Restricted Two-body Problem is a simplified dynamical model describing one small body (spacecraft, etc.) and one celestial body. The gravity of the celestial body exhibits a force on the small body. This model is commonly used as a simplification to descibe our solar systems' planets orbiting our sun, or a spacecraft orbiting Earth.

###### Usage

```julia
model = R2BSystem()
```

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
dynamics(orbit, args; kwargs...)

```

Return the underlying dynamics of the system in the form of a `ModelingToolkit.ODEFunction`.

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
parameters(orbit)

```

Return the parameter vector for an `Orbit`.

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
state(orbit)

```

Return the state vector for an `Orbit`.

:::


{{< pagebreak >}}



:::{.callout appearance="simple"}

```julia
system(orbit, args; kwargs...)

```

Return the underlying dynamics of the system in the form of a `ModelingToolkit.ODESystem`.

:::


{{< pagebreak >}}



:::
:::


