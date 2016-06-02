#!/bin/bash
set -e -x

if [ ! -r /krb5-1.14.2.tar.gz ]; then
    wget http://web.mit.edu/kerberos/dist/krb5/1.14/krb5-1.14.2.tar.gz
    tar -xf krb5-1.14.2.tar.gz
    (cd krb5-1.14.2/src && ./configure)
fi

cd krb5-1.14.2/src
./configure && make && make install

# Compile wheels
for PYBIN in /opt/python/*/bin; do
    ${PYBIN}/pip wheel /io/ -w wheelhouse/
done

# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    auditwheel repair $whl -w /io/wheelhouse/
done

# Install packages and test
for PYBIN in /opt/python/*/bin/; do
    ${PYBIN}/pip install python-manylinux-demo --no-index -f /io/wheelhouse
    (cd $HOME; ${PYBIN}/python -m unittest discover)
done
