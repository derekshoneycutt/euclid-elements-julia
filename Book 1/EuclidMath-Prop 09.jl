
""" I.9 Find a point that represents a bisection of an angle BAC """
function get_bisect_angle(A::Point2f, B::Point2f, C::Point2f)
    Bθ = vector_angle(A, B)
    Cθ = vector_angle(A, C)
    mid1 = (fix_angle(Bθ) + fix_angle(Cθ)) / 2
    # let D be the shorter of B and C
    AB = B-A
    AC = C-A
    norm_B = norm(AB)
    norm_C = norm(AC)
    norm_D = min(norm_B, norm_C)
    
    Point2f0([cos(mid1); sin(mid1)]*norm_D + A)
end
