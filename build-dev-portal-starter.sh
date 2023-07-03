#!/bin/sh

# Check that a Docker tag has been passed.
if [ -z "$1" ]
then
   echo "Please pass a tag that will be used for the DevPortalStarter Docker image as an argument to this script."
   exit 1
fi

DOCKER_IMAGE_TAG=$1

echo "Source nvm.sh to make nvm available to our script.\n"
. ~/.nvm/nvm.sh

echo "Set Yarn and NVM versions.\n"

yarn set version 1.22.19
nvm use 16


# Create the app using the laterst commit of the "dev-portal-starter" app
echo "Create the DevPortalUI application from solo-io/dev-portal-starter main.\n"
rm -rf portal-test
mkdir portal-test
pushd portal-test
npx tmplr solo-io/dev-portal-starter#main

# Change logo
# echo "Setting portal logo and banner!\n"
# cp ../solo.svg projects/ui/src/Assets/logo.svg
# cp ../mount-fuji.png projects/ui/src/Assets/banner.png
# cp ../mount-fuji.png projects/ui/src/Assets/banner@2x.png

pushd projects/ui 
echo "Create .env.local file with application configuration parameters.\n"
echo <<EOF 'VITE_PORTAL_SERVER_URL="http://developer.example.com/v1"
VITE_TOKEN_ENDPOINT="http://keycloak.example.com/realms/master/protocol/openid-connect/token"
VITE_AUTH_ENDPOINT="http://keycloak.example.com/realms/master/protocol/openid-connect/auth"
VITE_LOGOUT_ENDPOINT="http://keycloak.example.com/realms/master/protocol/openid-connect/logout"
VITE_CLIENT_ID="portal-client"' > .env.local
EOF
popd

# Set the image architecture.
# sed -i'.orig' -e 's/amd64/arm64/g' Makefile
# rm Makefile.orig
# sed -i'.orig' -e 's/amd64/arm64/g' Dockerfile
# rm Dockerfile.orig

make install-tools

CONTAINER_IMAGE_NAME="portal-frontend"

# IMAGE_NAME="$CONTAINER_IMAGE_NAME" \
# make build-ui-image

# Not using Makefile build-ui-image, as we want to do a multi-arch build.
docker buildx build --platform linux/amd64,linux/arm64 -t duncandoyle/$CONTAINER_IMAGE_NAME --push .
#docker buildx build --platform linux/amd64,linux/arm64 -t $CONTAINER_IMAGE_NAME --load .

docker tag $CONTAINER_IMAGE_NAME:latest $CONTAINER_IMAGE_NAME:$1