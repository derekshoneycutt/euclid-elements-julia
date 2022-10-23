include("EuclidMath-Core.jl")



""" I.1 Find the third point that constructs an equilateral triangle from 2 points"""
function equilateral_from(A::Point2f, B::Point2f)
    #basically, the idea is pull the vector and rotate it 60° to find the 3rd equaliteral point
    v = B-A
    r = norm(v)

    u_θ = vector_angle(A, B)

    θ = π/3 + u_θ
    x, y = [r*cos(θ), r*sin(θ)]+A
    Point2f0(x, y)
end;




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



""" I.3 Find the point that would cut a line equal """
function cut_line(A1::Point2f, B1::Point2f, A2::Point2f, B2::Point2f)
    # In Euclid, we get D to form a straight line AD the same length as C, then define circle DEF at center A, with radius AD
    # this is redundant and the radius of DEF is always norm(B2-A2), so just skip ahead :)
    r_DEF = norm(B2-A2)
    v = B1 - A1
    u = v / norm(v)
    E_x,E_y = A1 + r_DEF*u
    Point2f0(E_x,E_y)
end