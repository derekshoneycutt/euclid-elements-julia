include("../EuclidMath-Core.jl")

include("EuclidMath-Prop 01.jl")


""" I.2 At one given point, get a point to draw a line equal to a line from 2 given points"""
function equal_line(A::Point2f, B::Point2f, C::Point2f)
    # Get an equilateral triangle, DAB
    D = equilateral_from(A,B)

    # In Euclid, we get straight lines AE, BF, straight from DA, DB -- this is redundant...
    # We just skip to finding G and L via DB extended to DG and DA extended to DL

    # Circle CGH with center B, radius BC
    r_CGH = norm(B-C)
    G = continue_line(D, B, r_CGH)

    # Circle GKL with center D, radius DG
    r_GKL = norm(D-G)
    continue_line(D, A, r_GKL - norm(D-A)) #L
end;
