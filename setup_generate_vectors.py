from distutils.core import setup
from Cython.Build import cythonize

setup(
	name = 'Generate vectors within constraints',
	ext_modules = cythonize( 'generate_vectors.pyx' ),
)
