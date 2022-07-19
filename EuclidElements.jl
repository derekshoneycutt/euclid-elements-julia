using LinearAlgebra;
using Symbolics;
using Latexify;
using GLMakie;

# Calculate distance
function distance(p1::Point2, p2::Point2)
    √((p2[1] - p1[1])^2 + (p2[2] - p1[2])^2)
end;

# Find a point that will continue the given line, and the slope of the line
function continue_line(A::Point2, B::Point2, adjust_x=5)
    v = B - A
    u = v / norm(v)
    x,y = B + adjust_x*u
    Point2(x, y)
end;



# I.1 Find the third point that constructs an equilateral triangle from 2 points
function equilateral_from(A::Point2, B::Point2)
    r = distance(A, B)
    if B[1] == A[1]
        θ = B[1] > A[1] ? 3π/2 : π/2
    else
        θ = acos(((B[1]-A[1])^2 + r^2 - (B[2]-A[2])^2) / (2*(B[1]-A[1])*r))
    end
    if B[2] < A[2]
        θ = -θ
    end
    x, y = [cos(θ) -sin(θ); sin(θ) cos(θ)]*[ r/2, (r*√3)/2 ] + A
    Point2(x, y)
end;


# I.2 At one given point, get a point to draw a line equal to a line from 2 given points
function equal_line(A::Point2, B::Point2, C::Point2)
    # Get an equilateral triangle, DAB
    D = equilateral_from(A,B)

    #Get straight lines AE, BF, straight from DA, DB
    r_BC = distance(B,C)
    E = continue_line(A, D, r_BC + 2)
    F = continue_line(B, D, r_BC + 2)

    # Circle CGH with center B, radius BC
    r_CGH = distance(B,C)
    G = continue_line(D, B, r_CGH)

    # Circle GKL with center D, radius DG (math!)
    r_GKL = distance(D,G)
    L = continue_line(D, A, r_GKL - distance(D,A))

    L
end;


# I.3 Find the point that would cut a line equal 
function cut_line(A1::Point2, B1::Point2, A2::Point2, B2::Point2)
    # Get D to form a straight line AD the same length as C
    D = equal_line(A1, A2, B2)
    
    # Define circle DEF at center A, with radius AD
    r_DEF = distance(A1,D)
    v = B1 - A
    u = v / norm(v)
    E = A1 + r_DEF*u
end