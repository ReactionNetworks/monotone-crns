#!/usr/bin/env python

##
# Generate a set of lexicographically ordered vectors
#
# Returns a three-dimensional list. The outer list is the list of all
# possible distinct sets of lexicographically ordered vectors. The
# second-level lists are each a set of lexicographically ordered
# vectors. The third-level, innermost lists are individual vectors
# within a set.
#
# @author     Pete Donnell <pete dot donnell at port dot ac dot uk>
# @copyright  University of Portsmouth 2014
# @license    https://gnu.org/licenses/gpl-3.0-standalone.html GPLv3 or later
# @date       19/05/2014
##

import copy
import errno
import itertools
import numpy
import sys


##
# Increment a lexicographically-ordered vector
#
# TODO: throw exception on error, instead of sys.exit()
#
# @param   vector   numpy.array  Vector to increment
# @param   limit    int          Maximum value allowed in each entry of the vector
# @param   offset   int          Offset value for each entry of the vector
# @param   step     numeric      Step size to increment by - beware float issues when not an int
# @return  success  bool         True if vector was successfully incremented, False if the vector was already its maximum value
##

def increment_vector( vector, limit, offset = 0, step = 1 ):
	length = len( vector )
	# Check that all elemnts of the vector started within allowed bounds
	for i in range( 0, length ):
		if vector[i] < offset or vector[i] > limit:
			print( 'Error: ' + str( vector[i] ) + ' is out of the allowed range ' + str( offset ) + '-' + str( limit ) + '.' )
			sys.exit( errno.EDOM )
	# Increment the first element of the vector that is below the allowed limit, if possible
	for i in range( 0, length ):
		if vector[i] < limit:
			vector[i] += step
			return True
		for j in range( 0, i + 1 ):
			vector[j] = offset
	# If all of the elements of the vector are already at their limit:
	return False


##
# Generate all possible vectors within given constraints
#
# Examples: To generate all possible sets of binary vectors in 5D,
# call with generate_vectors( 5, 1, 0 ). To generate all possible
# sets of { -1, 0, 1, 2 }-vectors in 3D, call with
# generate_vectors( 3, 3, -1 ).
#
# @param   dimension    int                Dimension of the vectors to generate
# @param   base         int                Maximum value allowed in each vector
# @param   offset       int                Offset value for each entry of each vector
# @param   step         int                Step size to use when generating vectors
# @return  all_vectors  list<numpy.array>  List of all possible sets of vectors
##

def generate_vectors( dimension, base, offset = 0, step = 1 ):
	vector = numpy.array( [offset] * dimension )
	all_vectors = []
	if numpy.count_nonzero( vector ) > 0:
		# Need to use copy here as NumPy arrays are mutable and hence passed by reference
		all_vectors.append( copy.copy( vector ) )
	while increment_vector( vector, base + offset, offset, step ):
		if numpy.count_nonzero( vector ) > 0:
			all_vectors.append( copy.copy( vector ) )
	return all_vectors

'''
# Generate all possible vectors, then all possible n-tuples of them using itertools combinatorics
all_vectors = generate_vectors( dimension = 2, base = 1, offset = 0 )
print(all_vectors)
number_of_vectors = 4
vectors = [vector for vector in itertools.combinations( all_vectors, number_of_vectors )]
print( vectors )
'''

##
# Strictly compare two arrays
#
# Earlier entries are more significant, e.g. [1, 0, 0] > [0, 1, 1].
#
# @param   array1  iterable  The array which is tested to be greater
# @param   array2  iterable  The array which is tested to be lesser
# @return          bool      True if array1 > array2, False otherwise
##
def array_greater_than( array1, array2 ):
	for i in range( len( array1 ) ):
		if array1[i] > array2[i]:
			return True
		elif array1[i] < array2[i]:
			return False
	# All elements equal:
	return False

##
# Compare two arrays
#
# Earlier entries are more significant, e.g. [1, 0, 0] > [0, 1, 1].
#
# @param   array1  iterable  The array which is tested to be greater
# @param   array2  iterable  The array which is tested to be lesser
# @return          bool      True if array1 >= array2, False otherwise
##
def array_greater_than_or_equal( array1, array2 ):
	for i in range( len( array1 ) ):
		if array1[i] > array2[i]:
			return True
		elif array1[i] < array2[i]:
			return False
	# All elements equal:
	return True
