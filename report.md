# Project Report: Modeling and Simulation of Breast Can

## 1. Introduction

This project explores various differential equation-based models, including a **Universal Differential Equation (UDE) Model**, an **Oscillatory Pendulum Model**, a **Breast Cancer Model**, and a **Lorenz Attractor Model**. The study leverages numerical solvers, neural networks, and parameter estimation to analyze complex dynamical systems. The focus is on **data-driven approaches**, where missing dynamics are learned using neural networks, making these models more adaptable to real-world scenarios.

## 2. Methodologies and Experiments

### 2.1 Oscillatory Pendulum Model

#### Equations and Problem Formulation

The oscillatory pendulum model is governed by the equations:
$\frac{d\theta}{dt} = \omega$
$\frac{d\omega}{dt} = -\frac{3g}{2l} \sin(\theta) + \frac{3}{ml^2} M(t)$
where:

- $\theta$ represents the angular displacement.
- $\omega$ represents the angular velocity.
- $g$ is the gravitational constant.
- $l$ is the length of the pendulum.
- $m$ is the mass of the pendulum.
- $M(t)$ represents an applied torque.

#### Implementation and Solution

We define the system using **DifferentialEquations.jl** and solve it using an ODE solver:

```julia
using DifferentialEquations

function pendulum!(du, u, p, t)
    theta, omega = u
    g, l, m, mt = p
    du[1] = omega
    du[2] = -((3g) / (2l)) * sin(theta) + ((3 / m * l^2) * mt)
end

tspan = (0.0, 10.0)
l, m, g, mt = 1.0, 1.0, 9.81, 2.0
p = (g, l, m, mt)
u_0 = [0.001, 0.0]
problem = ODEProblem(pendulum!, u_0, tspan, p)
sol = solve(problem)
```

#### Results and Discussion

The simulation results indicate oscillatory behavior influenced by the applied torque. Below is a visualization of the pendulum's motion over time.

*(Include plot images here)*

### 2.2 Universal Differential Equation (UDE) Model

#### Model Description

The **Lotka-Volterra** predator-prey equations were modified to integrate neural networks into the unknown interaction terms:
$\frac{dx}{dt} = \alpha x - \beta xy + U(x, y)$
$\frac{dy}{dt} = \gamma xy - \delta y + U(x, y)$
where the neural network $U(x, y)$ learns the interaction term, making the model **data-driven**.

#### Implementation and Training

A **Lux.jl** neural network with **ADAM** and **BFGS** optimizers was trained to approximate the missing interaction term.

```julia
const U = Lux.Chain(Lux.Dense(2, 5, rbf), Lux.Dense(5, 5, rbf), Lux.Dense(5, 5, rbf), Lux.Dense(5, 2))
p, st = Lux.setup(rng, U)
```

The optimization was performed using:

```julia
res1 = Optimization.solve(optprob, ADAM(), callback = callback, maxiters = 5000)
res2 = Optimization.solve(optprob2, Optim.LBFGS(), callback = callback, maxiters = 1000)
```

#### Results and Visualizations

Training loss convergence and interaction predictions were compared to the ground truth.

*(Include training loss and reconstruction error plots here)*

### 2.3 Breast Cancer Model

#### Equations and Parameters

The breast cancer model follows logistic growth with treatment effects:
$\frac{dN}{dt} = rN(1 - \frac{N}{K}) - dN$
where:

- $N$ is the tumor size.
- $r$ is the growth rate.
- $K$ is the carrying capacity.
- $d$ represents treatment-induced death rate.

#### Implementation and Numerical Simulation

```julia
function cancer!(du, u, p, t)
    r, K, d = p
    du[1] = r * u[1] * (1 - u[1] / K) - d * u[1]
end
```

The tumor dynamics were simulated for different treatment strategies.

#### Results and Interpretation

Plots illustrate tumor progression under various conditions, showcasing how different treatment rates impact tumor reduction.

*(Include tumor growth plots here)*

### 2.4 Lorenz Attractor Model

#### System Equations

The **Lorenz system** is given by:
$\frac{dx}{dt} = \sigma (y - x)$
$\frac{dy}{dt} = x(\rho - z) - y$
$\frac{dz}{dt} = xy - \beta z$
where $\sigma, \rho, \beta$ are system parameters.

#### Numerical Simulation and Chaos Analysis

Using **DifferentialEquations.jl**, the chaotic trajectory was computed:

```julia
using DifferentialEquations
function lorenz!(du, u, p, t)
    sigma, rho, beta = p
    du[1] = sigma * (u[2] - u[1])
    du[2] = u[1] * (rho - u[3]) - u[2]
    du[3] = u[1] * u[2] - beta * u[3]
end
```

The phase-space plots illustrate the butterfly-shaped Lorenz attractor, a hallmark of chaotic systems.

*(Include Lorenz attractor visualizations here)*

## 3. Conclusion

This study examined diverse dynamical systems using differential equations and neural networks. The **UDE model** successfully approximated missing interaction terms, demonstrating the **power of data-driven modeling**. The **pendulum model** captured oscillatory motion under torque, the **breast cancer model** provided insights into tumor growth dynamics under treatment, and the **Lorenz system** illustrated chaotic behavior.

These findings showcase the potential of computational and machine learning-enhanced differential equation models in physics and biology.

## 4. Future Work

- Extend the UDE framework to high-dimensional chaotic systems.
- Implement real-world data-driven calibration for cancer treatment modeling.
- Analyze bifurcation behaviors in the Lorenz system.
- Explore hybrid models combining physics-based simulations with deep learning.
