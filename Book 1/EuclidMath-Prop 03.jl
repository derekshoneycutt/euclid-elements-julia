
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
