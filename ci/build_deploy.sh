#! /bin/bash

if [[ -z "$PYPI_USERNAME" || -z "$PYPI_PASSWORD" || -z "$PYPI_URL" ]]; then
    echo "You must set PYPI_USERNAME, PYPI_PASSWORD, and PYPI_URL to run this script"
    exit 1
fi
echo "Required environment variables are set ..."

# Write the short version into file and make a long version with the shorthash
SHORT_HASH=$(git rev-parse --short HEAD)  # also: TRAVIS_COMMIT
echo "Short hash: ${SHORT_HASH}"

# Take only the first string. Discards other strings
a=($(cat version.txt | xargs))
# version_no=${a[0]}

BUILD_VERSION=${a[0]}.${TRAVIS_BUILD_NUMBER}
echo "BUILD_VERSION: ${BUILD_VERSION}"
echo ${BUILD_VERSION} > version.txt
BUILD_VERSION=${BUILD_VERSION}-${SHORT_HASH}
echo "Could use the following for conda: $BUILD_VERSION"

echo "Setting up pypi connection info ..."
cat << EOF > /root/.pypirc
[distutils]
index-servers=pypi

[pypi]
repository=${PYPI_URL}
username=${PYPI_USERNAME}
password=${PYPI_PASSWORD}
EOF

echo "Finally: Building package ..."
python setup.py sdist bdist_wheel
echo "Uploading to pypi ($PYPI_URL) ..."
twine upload dist/*
