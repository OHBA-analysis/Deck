
//==================================================
// @title        J.H. Mex Library
// @author       Jonathan Hadida
// @contact      Jhadida87 [at] gmail
//==================================================

#include "main.h"

// ------------------------------------------------------------------------

namespace jmx_types {

    template<> const mxClassID cpp2mex<bool>::classid      = mxLOGICAL_CLASS;
    template<> const mxClassID cpp2mex<int8_t>::classid    = mxINT8_CLASS;
    template<> const mxClassID cpp2mex<uint8_t>::classid   = mxUINT8_CLASS;
    template<> const mxClassID cpp2mex<int16_t>::classid   = mxINT16_CLASS;
    template<> const mxClassID cpp2mex<uint16_t>::classid  = mxUINT16_CLASS;
    template<> const mxClassID cpp2mex<int32_t>::classid   = mxINT32_CLASS;
    template<> const mxClassID cpp2mex<uint32_t>::classid  = mxUINT32_CLASS;
    template<> const mxClassID cpp2mex<int64_t>::classid   = mxINT64_CLASS;
    template<> const mxClassID cpp2mex<uint64_t>::classid  = mxUINT64_CLASS;
    template<> const mxClassID cpp2mex<float>::classid     = mxSINGLE_CLASS;
    template<> const mxClassID cpp2mex<double>::classid    = mxDOUBLE_CLASS;
    
}

// ------------------------------------------------------------------------

namespace jmx {

    void cout_redirect( bool status )
    {
        static std::unique_ptr< coutRedirection<mexPrintf_ostream> > r;

        if ( status && !r )
            r.reset( new coutRedirection<mexPrintf_ostream>() );

        if ( !status )
            r.reset();
    }
    
    // ----------  =====  ----------
    
    int set_field( mxArray *mxs, index_t index, const char *field, mxArray *value )
    {
        JMX_ASSERT( mxs, "Null pointer." );
        JMX_ASSERT( mxIsStruct(mxs), "Input is not a struct." );

        // try to find the corresponding field
        int fnum = mxGetFieldNumber( mxs, field );

        // the field exists, check if there is something there
        if ( fnum >= 0 )
        {
            mxArray *fval = mxGetFieldByNumber( mxs, index, fnum );

            // there is something, so delete it first
            if ( fval ) mxDestroyArray( fval );
        }
        else // the field doesn't exist, so create it
        {
            fnum = mxAddField( mxs, field );
        }

        // set the value now
        mxSetField( mxs, index, field, value );

        return fnum;
    }

    int set_cell( mxArray *mxc, index_t index, mxArray *value )
    {
        JMX_ASSERT( mxc, "Null pointer." );
        JMX_ASSERT( mxIsCell(mxc), "Input is not a cell." );

        mxSetCell( mxc, index, value );
        return 0; // mxSetCell doesn't return a status...
    }

    int set_variable( MATFile *mtf, const char *name, mxArray *value )
    {
        JMX_ASSERT( mtf, "Null pointer." );
        return matPutVariable( mtf, name, value );
    }
    
    // ----------  =====  ----------
    
    std::string get_string( const mxArray *ms ) 
    {
        JMX_ASSERT( ms, "Null pointer." );
        JMX_ASSERT( mxIsChar(ms), "Input is not a string." );

        std::string val;
        val.resize( mxGetNumberOfElements(ms) );
        mxGetString( ms, &val[0], val.size()+1 );
        return val;
    }
    
    // ----------  =====  ----------
    
    void AbstractMapping::clear() 
    {
        m_fields.clear();
        m_fmap.clear();
    }

    bool AbstractMapping::has_any( const inilst<const char*>& names ) const
    {
        for ( auto& name: names )
            if ( has_field(name) )
                return true;

        return false;
    }

    bool AbstractMapping::has_fields ( const inilst<const char*>& names ) const
    {
        for ( auto& name: names ) 
            if ( !has_field(name) ) 
            {
                println( "Field '%s' doesn't exist.", name );
                return false;
            }
        return true;
    }
    
    // ----------  =====  ----------
    
    void MAT::clear() 
    {
        if (mfile) matClose(mfile);

        mfile = nullptr;
        AbstractMapping::clear();
    }

    bool MAT::open( const char *name )
    {
        clear();
        JMX_ASSERT( name, "Null filename." );

        MATFile *mf = matOpen( name, "r" );
        JMX_ASSERT( mf, "Error opening file: %s", name );

        int nf = 0;
        const char **fnames = (const char**) matGetDir( mf, &nf );
        JMX_WREJECT( nf == 0, "Empty file." );

        mfile = mf;
        this->m_fields.resize(nf);

        for ( int f = 0; f < nf; ++f )
        {
            this->m_fields[f] = fnames[f];
            this->m_fmap[ this->m_fields[f] ] = matGetVariable( mf, fnames[f] );
        }

        return true;
    }
    
    // ----------  =====  ----------
    
    void Cell::wrap( const mxArray *ms ) 
    {
        JMX_ASSERT( ms, "Null pointer." );
        JMX_ASSERT( mxIsCell(ms), "Input is not a cell." );

        int nc = mxGetNumberOfElements(ms);
        JMX_WREJECT( nc == 0, "Empty cell." );

        mcell = ms;
    }

    // ----------  =====  ----------
    
    void Struct::clear()
    {
        mstruct = nullptr;
        AbstractMapping::clear();
    }

    bool Struct::wrap( const mxArray* ms, index_t index )
    {
        clear();
        JMX_ASSERT( ms, "Null pointer." );
        JMX_ASSERT( mxIsStruct(ms), "Input is not a structure." );

        const index_t nf = mxGetNumberOfFields(ms);
        JMX_WREJECT( nf == 0, "Empty struct." );

        mstruct = ms;
        this->m_fields.resize(nf);

        for ( index_t f = 0; f < nf; ++f )
        {
            this->m_fields[f] = mxGetFieldNameByNumber(ms,f);
            this->m_fmap[ this->m_fields[f] ] = mxGetFieldByNumber(ms,index,f);
        }

        return true;
    }

}
