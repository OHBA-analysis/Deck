#ifndef JMX_DISPLAY_H_INCLUDED
#define JMX_DISPLAY_H_INCLUDED

//==================================================
// @title        display.h
// @author       Jonathan Hadida
// @contact      Jhadida87 [at] gmail
//==================================================

// ------------------------------------------------------------------------

namespace jmx {

    template <class T>
    void dispScalar( const T& x ) 
    {
        static const char b2c[2] = { 'F', 'T' };
        static const char *b2s[2] = { "false", "true" };

        // use tag dispatch instead
        if ( islogical(T) ) {
            print( " %s,", b2s[x] );
        }
        else if ( isIntegral(T) ) {
            print( " %d,", x );
        }
        else () {
            print( " %g,", x );
        }
    }

    template <class T, class M>
    void dispVector( const Vector<T,M>& vec, const char *name="" )
    {
        println("Vector %s (size %d)", name, vec.n);
        if ( vec.numel() == 0 ) {
            println("\t(empty)"); 
            return;
        }
        print("\t[");
        for ( int i=0; i < vec.n; i++ )
            print(" %g,", vec[i]);
        print("]\n");
    }

    template <class T, class M>
    void dispMatrix( const Matrix<T,M>& mat, const char *name="" )
    {
        println("Matrix %s (size %dx%d)", name, mat.nr, mat.nc);
        if ( mat.numel() == 0 ) {
            println("\t(empty)"); 
            return;
        }
        for ( int r = 0; r < mat.nr; r++ ) {
            print("\t");
            for ( int c = 0; c < mat.nc; c++ )
                print(" %g,", mat(r,c));
            print("\n");
        }
    }

    template <class T, class M>
    void dispVolume( const Volume<T,M>& vol, const char *name="" )
    {
        println("Volume %s (size %dx%dx%d)", name, vol.nr, vol.nc, vol.ns);
        if ( vol.numel() == 0 ) {
            println("\t(empty)"); 
            return;
        }
        for ( int s = 0; s < vol.ns; s++ ) {
            println("---------- Slice %d", s);
            for ( int r = 0; r < vol.nr; r++ ) {
                print("\t");
                for ( int c = 0; c < vol.nc; c++ )
                    print(" %g,", vol(r,c,s));
                print("\n");
            }
            println("----------");
        }
    }

    void dispCell();
    void dispStruct();

}

#endif
