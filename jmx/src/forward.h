#ifndef JMX_FORWARD_H_INCLUDED
#define JMX_FORWARD_H_INCLUDED

namespace jmx {

    /**
     * The following definitions were forwarded from files:
     *      getters.h
     *      extractor.h
     *      creator.h
     * 
     * to allow mappable types (see mapping.h/Abstract) to implement
     * the Extractor / Creator interfaces. Since Struct is a mappable
     * type itself, the following functions/methods could not be implemented
     * before its full definition.
     * 
     * This is a bit of a mind-bending inheritance dependency; 
     * it's not pretty, but it works.
     */
    
    inline Struct get_struct( const mxArray *ms, index_t index ) {
        return Struct(ms, index);
    }

    template <class K>
    inline Struct Extractor<K>::getstruct( key_t k, index_t i ) 
        { return get_struct( _extractor_get(k), i ); }

    template <class K>
    inline Struct Creator<K>::mkstruct( key_t k, inilst<const char*> fields, index_t nr, index_t nc ) {
        return Struct( _creator_assign(k, make_struct( fields, nr, nc )) );
    }

    template <class K>
    inline Struct Creator<K>::mkstruct( key_t k, inilst<const char*> fields )
        { return mkstruct(k,fields,1,1); }
    
    // ------------------------------------------------------------------------
    
    class Cell 
        : public Creator<index_t>, public Extractor<index_t>
    {
    public:

        Cell()
            { clear(); }
        Cell( const mxArray *ms )
            { wrap(ms); }

        inline void clear()
            { mcell = nullptr; }

        void wrap( const mxArray *ms );
        inline const mxArray* mx() const { return mcell; }
            
        inline index_t  numel () const { return mxGetNumberOfElements(mcell); }
        inline bool     empty () const { return numel() == 0; }
        inline bool     valid () const { return mcell && mxIsCell(mcell); }
        inline operator bool  () const { return valid() && !empty(); }

        inline mxArray* operator[] ( index_t index ) const { return get_value(index); }
        inline mxArray* get_value  ( index_t index ) const { return mxGetCell(mcell, index); }

        inline int set_value( index_t index, mxArray *value ) const {
            return set_cell( const_cast<mxArray*>(mcell), index, value );
        }

        // extractor/creator interface
        using key_t = Extractor<index_t>::key_t;
        using inptr_t = Extractor<index_t>::ptr_t;
        using outptr_t = Creator<index_t>::ptr_t;

        virtual inline bool _extractor_valid_key( key_t k ) const { return k < numel(); }
        virtual inline inptr_t _extractor_get( key_t k ) const { return get_value(k); }
        virtual inline outptr_t _creator_assign( key_t k, outptr_t val ) { set_value(k,val); return val; }

    private: 

        const mxArray *mcell;
    };
    
    // ----------  =====  ----------
    
    inline Cell get_cell( const mxArray *ms ) {
        return Cell(ms);
    }

    template <class K>
    inline Cell Extractor<K>::getcell( key_t k )
        { return get_cell(_extractor_get(k)); }

    template <class K>
    inline Cell Creator<K>::mkcell( key_t k, index_t len ) {
        return Cell( _creator_assign(k, make_cell( len )) );
    }

}

#endif