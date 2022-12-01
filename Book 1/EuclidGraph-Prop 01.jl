
""" Describe a representation of drawing an equilateral triangle via Euclid """
struct EuclidEquilTri
    A::Point2f0
    B::Point2f0
    C::Point2f0
    BCD::EuclidCircle
    ACE::EuclidCircle
    AC::EuclidLine
    BC::EuclidLine
end

""" Get the point that forms an equilateral triangle on a previously given line """
function Point(tri::EuclidEquilTri)
    tri.C
end

""" Construct an equilateral triangle on top of a given line AB, via Euclid """
function equilateral_triangle(A::Point2f0, B::Point2f0;
                                cursorcolor=:red, color=:black, linewidth::Float32=1f0, cursorlw=0.1f0)
    # Let AB be the given finite straight line

    # Thus it is required to construct an equilateral triangle on the straight line AB.
    # With center A and distance AB let the circle BCD be described; [Post. 3]
    r = norm(B-A)
    startθ1 = vector_angle(A, B)
    BCD = whole_circle(A, r, startθ1, cursorcolor=cursorcolor, color=color, linewidth=linewidth)

    # again, with centre B and distance BA let the circle ACE be described; [Post. 3]
    startθ2 = vector_angle(B, A)
    ACE = whole_circle(B, r, startθ2, cursorcolor=cursorcolor, color=color, linewidth=linewidth)

    # and from the point C, in which the circles cut one another, 
    # to the points A, B let the straight lines CA, CB be joined [Post. 1]
    #           ASIDE: this is unit circle 60° * r because equilateral triangles have 3 60° angles
    C = equilateral_from(A, B)
    CA = straight_line(C, A, cursorcolor=cursorcolor, color=color, linewidth=linewidth, cursorwidth=cursorlw)
    CB = straight_line(C, B, cursorcolor=cursorcolor, color=color, linewidth=linewidth, cursorwidth=cursorlw)

    # Now, since the point A is the centre of the circle CDB, AC is equal to AB. [Def. 15]
    # Again, since the point B is the ccentre of the circle CAE, BC is equal to BA. [Def. 15]

    # But CA was also proved equal to AB; therefore each of the straight lines CA, CB is equal to AB.

    # And things which are equal to the same thing are also equal to one another; [C.N. 1]
    #   therefore CA is also equal to CB.

    # Therefore the three straight lines CA, AB, BC are equal to one another.
    # Therefore the triangle ABC is equilateral; and it has been constructed on the given finite straight line AB.

    # Being what it was required to do.

    EuclidEquilTri(A, B, C, BCD, ACE, CA, CB)
end

""" Fill out the drawing of an equilateral triangle by Euclid """
function fill_equilateral(tri::EuclidEquilTri)
    fill_circle(tri.BCD)
    fill_circle(tri.ACE)
    fill_line(tri.AC)
    fill_line(tri.BC)
end

 """Animate the drawing of an equilateral triangle by Euclid"""
function animate_equilateral(tri::EuclidEquilTri, hide_until::AbstractFloat, max_at::AbstractFloat, t::AbstractFloat;
                                fade_start::AbstractFloat=0f0, fade_end::AbstractFloat=0f0)
    d(n, ofn=4) = hide_until + (n-1)*(max_at - hide_until)/ofn
    animate_circle(tri.BCD, d(1), d(2), t, fade_start=fade_start, fade_end=fade_end)
    animate_circle(tri.ACE, d(2), d(3), t, fade_start=fade_start, fade_end=fade_end)
    animate_line(tri.AC, d(3), d(4), t, fade_start=fade_start, fade_end=fade_end)
    animate_line(tri.BC, d(4), d(5), t, fade_start=fade_start, fade_end=fade_end)
end
