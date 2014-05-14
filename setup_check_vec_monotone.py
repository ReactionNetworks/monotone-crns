from distutils.core import setup
from Cython.Build import cythonize

setup(
	name = 'Check CRN vector preserves a cone',
	ext_modules = cythonize( 'check_vec_monotone.pyx' ),
)
