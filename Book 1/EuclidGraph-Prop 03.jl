
""" Represent Euclid's method for cutting a line into a segment equal to another, shorter line"""
struct EuclidCutLine
    A::Point2f0
    B::Point2f0
    C1::Point2f0
    C2::Point2f0
    EqualLine::EuclidEqualLine
    DEF::EuclidCircle
    E::Point2f0
end

""" Get a point that completes a EuclidCutLine representation"""
function Point(line::EuclidCutLine)
    line.E
end

""" Setup drawing for cutting one line equal to another shorter one"""
function draw_cut_line(A::Point2f0, B::Point2f0, C1::Point2f0, C2::Point2f0;
                        cursorcolor=:red, color=:black, linewidth::Float32=1f0, cursorlw::Float32=0.1f0)
    # Let AB, C be the two given unequal straight lines, and let AB be the greater of them.

    # Thus it is required to cut off from AB the greater a straight line equal to C the less.

    # At the point A let AD be placed equal to the straight line C; [I.2]
    AD = equivalent_line(A, C1, C2, cursorcolor=cursorcolor, color=color, linewidth=linewidth, cursorlw=cursorlw)
    D = Point(AD)

    # and with centre A and distance AD let hte circle DEF be described. [Post. 3]
    #           ASIDE: F is an arbitrary point on the circle, E is the intersection of AB and DEF
    r_DEF = norm(A-D)
    v = B - A
    u = v / norm(v)
    E = A + r_DEF*u
    DEF = whole_circle(A, r_DEF, vector_angle(A, E), cursorcolor=cursorcolor, color=color, linewidth=linewidth)
    #F = Point2f(r_DEF/2f0, -r_DEF*(√3f0)/2f0)

    # Now, since the point A is the centre of the circle DEF,
    #   AE is equal to AD. [Def. 15]

    # But C is also equal to AD.
    # Therefore each of the straight lines AE, C is equal to AD;
    #   so that AE is also equal to C. [C.N. 1]

    # Therefore, given the two straight lines AB, C, from AB the greater AE has been cut off equal to C the less.

    # Being what it was required to do

    EuclidCutLine(A, B, C1, C2, AD, DEF, E)
end

""" Fill out the drawing of a cut line, in all of its parts """
function fill_cut_line(line::EuclidCutLine)
    fill_equivalent(line.EqualLine)
    fill_circle(line.DEF)
end

""" Animate everything to show a line being cut equal to another, shorter one"""
function animate_cut_line(line::EuclidCutLine, hide_until::AbstractFloat, max_at::AbstractFloat, t::AbstractFloat;
                                fade_start::AbstractFloat=0f0, fade_end::AbstractFloat=0f0)
    d(n, ofn=2) = hide_until + (n-1)*(max_at - hide_until)/ofn
    animate_equivalent(line.EqualLine, d(1), d(2), t, fade_start=d(2.5), fade_end=max_at)
    animate_circle(line.DEF, d(2), max_at, t, fade_start=fade_start, fade_end=fade_end)
end
