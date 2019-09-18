
# Structures

Both structures and struct-arrays supported, but working with struct-arrays is somewhat complicated right now. Structures implement the [creator/extractor interfaces](jmx/more/interface) with key-type `const char*`.

## Usage

```cpp
index_t numel() const;
index_t nfields() const;
bool empty() const;

bool has_field( std::string name ) const;
bool has_fields( inilst<const char*> names ) const;
bool has_any( inilst<const char*> names ) const;

int set_value( std::string name, mxArray *value ) const;
mxArray* get_value( std::string name ) const;
mxArray* operator[] ( std::string name ) const;
```
