#!/bin/bash

depth(){
    #Do a small depth checking how deep into the tree we are
    k=0
    while [ $k -lt $1 ]; do
        echo -n "   "
        let k++
        #or use k=`expr $k + 1`
    done
}

traverse(){
    # Traverse a directory
    ls "$1" | while read i; do
        depth $2
        if [ -d "$1/$i" ]; then

            # It's a directory
            dname=$1/$i

            if [ "${i:0:1}" = "+" ]; then

                # It's a submodule, traverse it
                echo "Directory $dname"
                traverse "$dname" `expr $2 + 1`

            else

                # It's a normal directory, copy it
                echo "$dname -> $i"
                cp -r "$dname" "dk_flat/$i"
            fi

        else
            # It's a file
            fname=$1/$i

            if [ "${i: -2}" = ".m" ]; then

                # It's a Matlab file, flatten the name
                nname=$(echo "${fname//+}" | tr / _)
                echo "$fname -> $nname"
                cp "$fname" "dk_flat/$nname"
            else

                # It's a normal file, copy it with the same name
                echo "$fname -> $i"
                cp "$fname" "dk_flat/$i"
            fi
        fi
    done
}

# Remove directory if there
[ -d dk_flat ] && rm -rf dk_flat
mkdir dk_flat

# Run on the module directory
traverse +dk 0

# Any call to Deck has this form:
# 'dk\.[\._a-zA-Z0-9]+\s*'
#
# Expressions incompatible with flattening have this form:
# 'dk\.[\._a-zA-Z0-9]+\.\('
