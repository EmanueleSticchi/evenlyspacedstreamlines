function lines = evenly_spaced_streamlines(vertices, triangles, orientation, radius,...
                                    options)
% # Generate a set of evenly spaced streamlines on a triangulated surface
% # Args:
% #     vertices (nv-by-3 float array): x, y, z coordinates of the nv vertices
% #     triangles (nt-by-3 int array): indices of the vertices of the nt 
% #         triangles (1 based)
% #     orientation (nt-by-3 float array): orientation vector in each triangle
% #     radius (float): the distance between streamlines will be larger than 
% #         the radius and smaller than 2*radius
% # Optional keyword-only args:
% #     seed_points (int): number of seed points tested to generate each 
% #         streamline; the longest streamline is kept (default: 32)
% #     seed_region (int array): list of triangle indices among which seed 
% #         points are picked (default: None, which means that all triangles
% #         are considered)
% #     orthogonal (bool): if True, rotate the orientation by 90 degrees
% #         (default: False)
% #     oriented_streamlines (bool): if True, streamlines only follow the 
% #         vector field in the direction it points to (and not the opposite 
% #         direction); the outputted streamlines are then oriented according 
% #         to the vector field.
% #         If False (default), the orientation field is defined modulo pi 
% #         instead of 2pi
% #     allow_tweaking_orientation (bool): if an orientation vector is parallel
% #         to an edge of the triangle, a small random perturbation is applied 
% #         to that vector to satisfy the requirement (default: True); 
% #         otherwise an exception is raised when the requirement is not 
% #         satisfied
% #     singularity_mask_radius (float): when the orientation field has a 
% #         singularity (e.g. focus or node), prevent streamlines from entering
% #         a sphere of radius 'singularity_mask_radius' x 'radius' around 
% #         that singularity (default: 0.1)
% #     max_length (int): maximal number of iterations when tracing
% #         streamlines; it is needed because of nearly-periodic streamlines
% #         (default: 0, which means equal to the number of triangles)
% #     max_angle (float): stop streamline integration if the angle between
% #         two consecutive segments is larger than max_angle in degrees;
% #         0 means straight line and 180 means U-turn (default: 90)
% #     avoid_u_turns (bool): restrict high curvatures by maintaining a 
% #         lateral (perpendicular) distance of at least 'radius' between
% #         a segment of the streamline and the other segments of the same
% #         streamline; this automatically sets 'max_angle' to at most 
% #         90 degrees (default: True)
% #     random_seed (int): initialize the seed for pseudo-random number 
% #         generation (default: seed based on clock)
% #     max_reruns (int): maximum number of automatic reruns when random
% #         seeding fails while seed_region is empty (default: 5)
% #     parallel (bool): if True (default), use multithreading wherever 
% #         implemented
% #     num_threads (int): if possible, use that number of threads for parallel
% #         computing (default: let OpenMP choose)
% # Returns:
% #     lines (n-by-3 matrices): xyz coordinates of each of the streamlines separated by NaN.
% # ==========================================================================
arguments
    vertices (:,3)
    triangles (:,3)
    orientation (:,3)
    radius (1,1)
    options.orthogonal (1,1) logical = false;
    options.oriented_streamlines (1,1) logical = true;
    options.seed_points (1,1) {mustBePositive} = 32;
    options.seed_region=[];
    options.max_length (1,1) {mustBeNonnegative} = 0;
    options.avoid_u_turns (1,1) logical = true;
    options.max_angle (1,1) {mustBeInRange(options.max_angle,0,180,'inclusive')} = 90;
    options.singularity_mask_radius (1,1) {mustBePositive} = 0.1;
    options.allow_tweaking_orientation (1,1) logical = true;
    options.random_seed (1,1) = 0;
    options.max_reruns (1,1) {mustBePositive} = 5;
    options.parallel (1,1) logical = true;
    options.num_threads (1,1) = -1;
end
% # Check inputs =============================================================
% # ==========================================================================
Npoints = length(vertices); 
Ntri    = length(triangles);
% # check array sizes
if Ntri ~= length(orientation)
    error("Arguments 'triangles' and 'orientiation' must have the same number of rows.");
end

% # check bounds
if min(triangles(:)) < 1 || max(triangles(:)) > Npoints
    error("Vertex indices out of bounds")
end
% # ==========================================================================
% # call C extension
max_attempts = 1;
if isempty(options.seed_region)
    max_attempts = max(1, options.max_reruns);
end

for attempt = 1:max_attempts
    try
        lines = streamlines_uns(...
            vertices', int32(triangles'-1), orientation', radius,...
            int32(options.seed_region),options.orthogonal,options.oriented_streamlines,...
            options.seed_points,options.max_length,options.avoid_u_turns, options.max_angle,...
            options.singularity_mask_radius, options.allow_tweaking_orientation,...
            options.random_seed, options.parallel, options.num_threads);
        return
    catch ME
        if attempt == max_attempts
            error('Error while calling mex function after %d attempt(s). Last error:\n%s', attempt, ME.message);
        end

        fprintf('MEX call failed (attempt %d/%d): %s. Retrying...', attempt, max_attempts, ME.message);
    end
end
end
