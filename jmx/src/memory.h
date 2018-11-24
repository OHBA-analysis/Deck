#ifndef JMX_MEMORY_H_INCLUDED
#define JMX_MEMORY_H_INCLUDED

//==================================================
// @title        memory.h
// @author       Jonathan Hadida
// @contact      Jhadida87 [at] gmail
//==================================================

#include "common.h"

#include<type_traits>

// ------------------------------------------------------------------------

namespace jmx {
    
    template <class T>
    struct AbstractMemory
    {
        static_assert( ! std::is_const<T>::value, "Container type cannot be const." );

        T *data;
        index_t size;

        void clear()
        {
            data = nullptr;
            size = 0;
        }

        void assign( T* p, index_t n )
        {
            data = p;
            size = n;
        }

        virtual void alloc( index_t n ) =0;
        virtual void free() =0;
    };
    
    // ------------------------------------------------------------------------
    
    template <class T>
    struct ReadOnlyMemory : public AbstractMemory<T>
    {
        using value_type = typename std::add_const<T>::type;

        void alloc( index_t n )
            { JMX_THROW( "Read-only memory cannot be allocated." ); }

        void free()
            { JMX_THROW( "Read-only memory cannot be freed." ); }

        inline value_type& operator[] ( index_t k ) const { return this->data[k]; }
    };

    // ------------------------------------------------------------------------
    
    template <class T>
    struct MatlabMemory : public AbstractMemory<T>
    {
        using value_type = T;

        void alloc( index_t n )
        {
            this->data = static_cast<T*>( mxCalloc( n, sizeof(T) ) ); 
            this->size = n;
        }

        void free()
            { mxFree(this->data); this->clear(); }

        inline T& operator[] ( index_t k ) const { return this->data[k]; }
    };

    // ------------------------------------------------------------------------
    
    template <class T>
    struct CppMemory : public AbstractMemory<T>
    {
        using value_type = T;

        void alloc( index_t n )
        {
            this->data = new T[n](); 
            this->size = n;
        }

        void free()
            { delete[] this->data; this->clear(); }

        inline T& operator[] ( index_t k ) const { return this->data[k]; }
    };

}

#endif
