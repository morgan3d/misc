2D OBB Intersection

For 2D graphics or movement of 3D objects on a 2D ground plane it is often useful to discover
if the 2D oriented bounding boxes of two objects overlap (have a non-empty intersection).  One
motivating example is the placement of a new building in a Real-Time Strategy game.  The UI
needs to continuously check whether the footprint of the new building overlaps the footprint of
any existing building.  If there is any overlap, the UI should indicate that is an illegal
placement.

Stefan Gottschalk's thesis (Collision Queries using Oriented Bounding Boxes, Ph.D. Thesis,
Department of Computer Science, University of North Carolina at Chapel Hill, 1999) introduces
the separating-axis method for performing the equivalent test on 3D oriented bounding boxes.
This method depends on the observation that for two boxes to be disjoint (i.e. *not*
intersecting), there must be some axis along which their projections are disjoint.  The 3D case
considers each of 15 axes as a potential separating axis.  These axes are the three edge axes
of box 1, the three edge axes of box 2, and the nine cross products formed by taking some edge
of box 1 and some edge of box 2.
 
In 2D this simplifies dramatically and only four axes need be considered.  These are the
orthogonal edges of each bounding box.  If a few values are precomputed every time a box moves,
we end up performing only 16 dot products and some comparisons in the worst case for each
overlap test. One nice property of the separating-axis method is that it can be structured in
an early out fashion, so that many fewer operations are needed in the case where the boxes do
not intersect.  In general, the first test is extremely likely to fail (and return "no
overlap") when there is no overlap.  If it passes, the second test is even more likely to fail
if there is no overlap, and so on.  Only when the boxes are in extremely close proximity is
there even a 50% chance of executing more than 2 tests.
 
The C++ code sample provided efficiently computes this fast 2D oriented bounding box overlap.
I augmented the `OBB2D` class with some methods for rendering and construction to help visualize
the result.  `OBB2D::overlaps1Way` performs the real work.  It tests to see whether the box
passed as an argument overlaps the current box along either of the current box's dimensions.
Note that this test must be performed for each box on the other to determine whether there is
truly any overlap. To make the tests efficient, `OBB2D::origin` stores the projection
of corner number zero onto a box's axes and the axes are stored explicitly in `OBB2D::axis`.  The
magnitude of these stored axes is the inverse of the corresponding edge length so that all
overlap tests can be performed on the interval [0, 1] without normalization, and square roots
are avoided throughout the entire class.
 
Morgan McGuire Pre-2005
