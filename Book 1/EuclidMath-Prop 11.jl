
""" I.11 Get a point that forms a perpendicular from the second of two points on any line """
function get_perpendicular(A::Point2f, B::Point2f)
    #basically, the idea is pull the vector and rotate it 90°
    v = B-A
    r = norm(v)

    u_θ = vector_angle(A, B)

    θ = π/2 + u_θ
    x, y = [r*cos(θ), r*sin(θ)]+A
    Point2f0(x, y)
end;
