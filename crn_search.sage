#!/usr/bin/env sage

##
# Search for monotone CRNs
#
# TODO: write long description
#
# @author     Pete Donnell <pete dot donnell at port dot ac dot uk>
# @copyright  University of Portsmouth 2014
# @license    https://gnu.org/licenses/gpl-3.0-standalone.html GPLv3 or later
# @date       04/06/2014
##

# Custom libraries
import check_vec_monotone as cvm
import generate_vectors as gv
from sage.all import *


# Standard libraries
'''
N.B. ConfigParser was renamed to configparser in Python 3.x. NumPy and
Sage are using Python 2.x for the foreseeable future, so it's not a big
problem, but this will need fixing eventually when they upgrade to
Python 3.x. Also, the syntax has changed, so the ini file code will need
changing.
'''
# Python 2.x:
import ConfigParser
# Python 3.x:
#import configparser
import errno
import itertools
import numpy
import sys
import time

debug = False

start_time = time.time()

# Specify some base parameters to constrain the search space
if len( sys.argv ) != 3:
	print( 'Usage: crn_search.spyx <inifile>' )
	sys.exit( errno.EINVAL )

# Python 2.x version of ini file parser:
config = ConfigParser.ConfigParser()
config.read( sys.argv[2] )
dimension = config.getint( 'DEFAULT', 'dimension' )
dual_number_of_generators = config.getint( 'DEFAULT', 'dual_number_of_generators' )
dual_min = config.getint( 'DEFAULT', 'dual_min' )
dual_max = config.getint( 'DEFAULT', 'dual_max' )
crn_max = config.getint( 'DEFAULT', 'crn_max' )
show_interconversions = config.getboolean( 'DEFAULT', 'interconversions' )

'''
# Python 3.x version of ini file parser:
config = configparser.ConfigParser()
config.read( sys.argv[1] )
dimension = int( config['DEFAULT']['dimension'] )
dual_number_of_generators = int( config['DEFAULT']['dual_number_of_generators'] )
dual_min = int( config['DEFAULT']['dual_min'] )
dual_max = int( config['DEFAULT']['dual_max'] )
crn_max = int( config['DEFAULT']['crn_max'] )
show_interconversions = bool( config['DEFAULT']['interconversions'] )
'''

# Output parameters for reference
print( 'Start: ' + time.asctime( time.localtime( start_time ) ) )
print( '' )
print( 'Dimension = ' + str( dimension ) )
print( 'Dual number of generators = ' + str( dual_number_of_generators ) )
print( 'Dual generator minimum value = ' + str( dual_min ) )
print( 'Dual generator maximum value = ' + str( dual_max ) )
print( 'CRN vector maximum value = ' + str( crn_max ) )
print( 'Show interconversion networks = ' + str( show_interconversions ) )
print( '' )
print( '' )

# Calculate all possible sets of generators for the dual
dual_all_base_vectors = gv.generate_vectors( dimension, dual_max - dual_min, dual_min )

# Calculate all possible CRN vectors, ignoring oppositely signed duplicates
crn_vectors = gv.generate_vectors( dimension, 2 * crn_max, -crn_max )
crn_vectors = crn_vectors[:len( crn_vectors ) / 2]
if debug:
	print( 'CRN vectors to test are ' )
	print( crn_vectors )
	print( '' )

##
# Check whether a given CRN vector lies in the span of a given cone
#
# @param   vector      numpy.array  CRN vector
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
number_of_possible_cones = 0
for set_of_base_vectors in itertools.combinations(dual_all_base_vectors, dual_number_of_generators):
	number_of_possible_cones += 1
	if show_interconversions:
		noninterconversion_vector_found = True
	else:
		noninterconversion_vector_found = False
	preserved_crn_vectors = []
	reactant_non_outflow = [False] * dimension
	number_of_non_outflow_reactions = 0
	dual_cone = Cone( [generator.tolist() for generator in set_of_base_vectors] )
	if debug:
		print( str( dual_cone.rays() ) )

	# Check that rows of dual cone matrix are in lexicographic ordering
	lexicographic_ordering = True
	dual_cone_rays_temp = dual_cone.rays()
	dual_cone_column_matrix = dual_cone_rays_temp.column_matrix()
	rows = [row for row in dual_cone_column_matrix]
	for i in range( 1, len( rows ) ):
		if gv.array_greater_than( rows[i], rows[i-1] ):
			lexicographic_ordering = False
	# Check that dual is solid, ensuring that the cone is pointed, and that it has the full number of generators
	if lexicographic_ordering and dual_cone.dim() == dimension and len( dual_cone_rays_temp ) == dual_number_of_generators:
		cone = dual_cone.dual()
		cone_rays_temp = cone.rays()
		cone_number_of_generators = len( cone_rays_temp )
		for crn_vector in crn_vectors:
			if not cvm.not_red( crn_vector ):
				if debug:
					print( 'CRN vector ' + str( crn_vector ) + ' is not reduced.' )
				# Process
				cone_matrix = cone_rays_temp.column_matrix()
				dual_cone_matrix = dual_cone_rays_temp.matrix()
				cone_rays = numpy.array( [numpy.array( column_vector ) for column_vector in cone_matrix ] )
				dual_cone_rays = numpy.array( [numpy.array( column_vector ) for column_vector in dual_cone_matrix ] )
				if not vector_in_cone_span( crn_vector, cone ):
					print( 'CRN vector ' + str( crn_vector ) + ' preserves cone generated by' )
					print( cone_matrix )
					print( 'but does not lie in its span' )
				if cvm.CRNv( cone_rays, dual_cone_rays, crn_vector, dimension, dual_number_of_generators, cone_number_of_generators ):
					if numpy.count_nonzero( crn_vector ) > 1:
						for i in numpy.nonzero( crn_vector )[0]:
							reactant_non_outflow[i] = True
						number_of_non_outflow_reactions += 1
					if numpy.count_nonzero( crn_vector ) > 2:
						noninterconversion_vector_found = True
					preserved_crn_vectors.append( crn_vector )
					if debug:
						print( 'CRN vector ' + str( crn_vector ) + ' is monotone w.r.t. cone generated by columns of' )
						print( str( cone_matrix ) )
	elif debug:
		print( 'Dual cone ' + str( dual_cone.rays() ) + ' is not solid. Ignoring.' )
	if noninterconversion_vector_found and all( reactant_non_outflow ) and number_of_non_outflow_reactions > 1:
		# To do: check that the reaction network is indecomposable
		number_of_interesting_cones += 1
		print( 'The cone generated by the columns of' )
		print( str( cone_rays_temp.column_matrix() ) )
		print( 'with dual generated by the columns of' )
		print( str( dual_cone_rays_temp.column_matrix() ) )
		print( 'is preserved by the following CRN (row) vectors:' )
		for crn_vector in preserved_crn_vectors:
			print( str( crn_vector ) )
		print( '' )
print( '' )
if show_interconversions:
	print( 'Found ' + str( number_of_interesting_cones ) + ' cones that preserve two or more non-outflow reactions out of a total of ' + str( number_of_possible_cones ) + ' possible cones.' )
else:
	print( 'Found ' + str( number_of_interesting_cones ) + ' cones that preserve two or more non-outflow reactions, including at least one non-interconversion reaction, out of a total of ' + str( number_of_possible_cones ) + ' possible cones.' )
print( '' )
print( '' )

end_time = time.time()
print( 'End: ' + time.asctime( time.localtime( end_time ) ) )
print( 'Time elapsed: ' + str( end_time - start_time ) + ' seconds' )
