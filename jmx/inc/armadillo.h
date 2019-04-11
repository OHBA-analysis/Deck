#ifndef JMX_ARMADILLO_H_INCLUDED
#define JMX_ARMADILLO_H_INCLUDED

//==================================================
// @title        armadillo.h
// @author       Jonathan Hadida
// @contact      Jhadida87 [at] gmail
//==================================================

// Simple wrapper for Armadillo library
#ifdef JMX_64BIT
    #define ARMA_64BIT_WORD
    #define ARMA_BLAS_LONG_LONG
#endif 

#ifdef JMX_32BIT
    #define ARMA_32BIT_WORD
    #define ARMA_BLAS_LONG
#endif

#include "armadillo-code/include/armadillo"

#endif
