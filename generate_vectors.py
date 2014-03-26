#!/usr/bin/env python
#
# Generate a set of lexicographically ordered vectors
#
# Returns a three-dimensional list. The outer list is the list of all
# possible distinct sets of lexicographically ordered vectors. The
# second-level lists are each a set of lexicographically ordered
# vectors. The third-level, innermost lists are individual vectors
# within a set.
#
# @author Pete Donnell <pete dot donnell at port dot ac dot uk>
# @copyright University of Portsmouth 2014
# @date 26/03/2014

import copy


def increment_vector( in_vector, limit, offset ):
	vector = copy.copy( in_vector )
	length = len( vector )
	for i in range( 0, length ):
		if vector[i] < offset or vector[i] > limit:
			print( 'Error: ' + str( vector[i] ) + ' is out of the allowed range ' + str( offset ) + '-' + str( limit ) + '.' )
			exit( 1 )
	for i in range( 0, length ):
		if vector[i] < limit:
			vector[i] += 1
			return vector
		for j in range( 0, i + 1 ):
			vector[j] = offset
	return vector
			

# Generate all possible vectors within given constraints
#
# Examples: To generate all possible sets of 8 binary vectors in 5D,
# call with generate_vectors( 5, 8, 1, 0 ). To generate all possible
# sets of 4 { -1, 0, 1, 2 }-vectors in 3D, call with
# generate_vectors( 3, 4, 3, -1 )
#
# @param   dimension          int   Dimension of the vectors to generate
# @param   number_of_vectors  int   Desired number of vectors in each set
# @param   base               int   Maximum value allowed in each vector
# @param   offset             int   Offset value for each entry of each vector
# @return  sets_of_vectors    list  List of all possible sets of vectors

def generate_vectors( dimension, number_of_vectors, base, offset ):
	# Generate all possible vectors
	blank_vector = [offset] * dimension
	all_vectors = [blank_vector]
	vector = copy.copy( blank_vector )
	vector = increment_vector( vector, base + offset + 1, offset )
	while vector is not blank_vector:
		all_vectors.append( copy.copy( vector ) )
		print( vector )
		vector = increment_vector( vector, base + offset + 1, offset )
	return all_vectors

	# Select set of vectors
#	sets_of_vectors = []
#	return sets_of_vectors

vectors = generate_vectors( dimension = 2, number_of_vectors = 2, base = 1, offset = 0 )
print( vectors )
