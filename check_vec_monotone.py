#!/usr/bin/env python

# The space is of dimension d, the cone K has q generators, 
# while the dual K* has p generators

# Routine CRNv takes as its input (i) K: the cone
# (ii) Ks: the transposed dual, (iii) s: a vector
# (iv) d: the dimension of the space, (v) q: the 
# number of generators of K* (vi) p: the number of 
# generator of K
#
# It returns 

from numpy import linalg as LA
import numpy as NP

def CRNv(K,Ks,s,d,p,q):
    KK=NP.dot(Ks,K)
#    print(KK)
    for i in range(0, p): #rows of K* transposed
        for j in range(0, q): #cols of K
        #print("i=",i,"j=",j,"KK[i,j]=",KK[i,j]);
            if(KK[i,j]==0):
                for l in range(0, d): #dimension of space
                    #                print(Ks[i,:]*s)
                    if(NP.dot(Ks[i,:],s)*s[l]*K[l,j]>0): 
                        return 0;
    return 1;

#trying out the function

K=NP.array([[0,0,1,1],[0,1,0,-1],[1,0,-1,0]]) #cone n X q
Ks=NP.array([[1,1,1],[1,1,0],[1,0,1],[1,0,0]]) #dual p X n
s=NP.array([2,-2,-2])

suc=CRNv(K,Ks,s,3,4,4)
if(suc==1):
    print(str(s)+' successful');
else:
    print(str(s)+' failed');
    

# routine which returns 1 if a vector s is unreduced
# and 0 otherwise

def not_red(s,n): #not reduced
    for i in range(2, max(abs(s))+1):
        if all([v == 0 for v in s%i]):
            return 1
    return 0

#trying out the function
suc=not_red(s,3)
if(suc):
    print(str(s)+' is not reduced')
else:
    print(str(s)+' is reduced')
