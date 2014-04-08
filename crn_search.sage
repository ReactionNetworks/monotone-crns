#!/usr/bin/env sage

##
# Search for monotone CRNs
#
# To do: write long description
#
# @author Pete Donnell <pete dot donnell at port dot ac dot uk>
# @copyright University of Portsmouth 2014
# @date 08/04/2014
##

import check_vec_monotone as cvm
import generate_vectors as gv
import itertools
import numpy

# Specify some base parameters to constrain the search space
dimension = 3
dual_number_of_generators = 4
dual_min = 0
dual_max = 1
crn_min = -1
crn_max = 1

# Output parameters for reference
print( 'Dimension = ' + str( dimension ) )
print( 'Dual number of generators = ' + str( dual_number_of_generators ) )
print( 'Dual generator minimum value = ' + str( dual_min ) )
print( 'Dual generator maximum value = ' + str( dual_max ) )
print( 'CRN vector minimum value = ' + str( crn_min ) )
print( 'CRN vector maximum value = ' + str( crn_max ) )
print( '' )

# Calculate all possible sets of generators for the dual
dual_all_base_vectors = gv.generate_vectors( dimension, dual_max - dual_min, dual_min )
dual_base_vectors = [vector for vector in itertools.combinations(dual_all_base_vectors, dual_number_of_generators)]
#print( 'Sets of possible dual vectors are ' )
#print( dual_base_vectors )
#print( '' )

# Calculate all possible CRN vectors
crn_vectors = gv.generate_vectors( dimension, crn_max - crn_min, crn_min )
#print( 'CRN vectors to test are ' )
#print( crn_vectors )
#print( '' )

##
# Check whether a given CRN vector lies in the span of a given cone
#
# @param   crn_vector  numpy.array  CRN vector
# @param   cone        sage.Cone    Cone
# @return  is_in_span  bool         True if CRN vector is in span of cone, False if not
##
def vector_in_cone_span( vector, cone ):
	# Check that the cone and the vector live in the same space
	if cone.lattice_dim() != len(vector):
		return False
	original_cone_dim = cone.dim()
	# Check whether the cone is solid
	if original_cone_dim == cone.lattice_dim():
		return True
	# Add the vector to the generators of the cone and check whether a higher-dimensional cone is produced
	else:
		rays = [ray for ray in cone.rays()]
		rays.append( vector.tolist() )
		new_cone = Cone( rays )
		if original_cone_dim < new_cone.dim():
			return False
		else:
			return True

# Go through each possible dual, and test each CRN in turn
number_of_interesting_cones = 0
for set_of_base_vectors in dual_base_vectors:
	preserved_crn_vectors = []
	dual_cone = Cone( [generator.tolist() for generator in set_of_base_vectors] )
	#print( str( dual_cone.rays() ) )

	# Check that dual is solid, ensuring that the cone is pointed
	if dual_cone.dim() == dimension:
		cone = dual_cone.dual()
		cone_number_of_generators = len( cone.rays() )
		dual_cone_number_of_primitive_generators = len( dual_cone.rays() )
		for crn_vector in crn_vectors:
			if not cvm.not_red( crn_vector ):
				#print( 'CRN vector ' + str( crn_vector ) + ' is not reduced.' )
				# process
				cone_matrix = cone.rays().column_matrix()
				dual_cone_matrix = dual_cone.rays().matrix()
				cone_rays = numpy.array( [numpy.array( column_vector ) for column_vector in cone_matrix ] )
				dual_cone_rays = numpy.array( [numpy.array( column_vector ) for column_vector in dual_cone_matrix ] )
				if not vector_in_cone_span( crn_vector, cone ):
					print( 'CRN vector ' + str( crn_vector ) + ' preserves cone generated by' )
					print( cone_matrix )
					print( 'but does not lie in its span' )
				if cvm.CRNv( cone_rays, dual_cone_rays, crn_vector, dimension, dual_cone_number_of_primitive_generators, cone_number_of_generators ):
					preserved_crn_vectors.append( crn_vector )
					#print( 'CRN vector ' + str( crn_vector ) + ' is monotone w.r.t. cone generated by columns of' )
					#print( str( cone.rays().column_matrix() ) )
	#else:
		#print( 'Dual cone ' + str( dual_cone.rays() ) + ' is not solid. Ignoring.' )
	if len( preserved_crn_vectors ) > 2:
		number_of_interesting_cones += 1
		print( 'The cone generated by' )
		print( str( cone.rays().column_matrix() ) )
		print( 'is preserved by the following CRN vectors:' )
		for crn_vector in preserved_crn_vectors:
			print( str( crn_vector ) )
			if numpy.count_nonzero( crn_vector ) > 2:
				print( 'Monotone non-interconversion reaction found!' )
		print( '' )
print( 'Found ' + str( number_of_interesting_cones ) + ' cones that preserve two or more reactions out of a total of ' + str( len( dual_base_vectors ) ) + ' possible cones.' )
print( '' )
