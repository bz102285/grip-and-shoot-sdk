#Usage

# sh framework-build.sh [-v version-number] [-s]
# -s uploads to amazon s3
#

FRAMEWORK_FILE_NAME=ShelfbucksSDK.a

function failed () {
	echo "Failed: $@" >&2
}

while getopts :v:s opt; do
	case $opt in
		v)
			VERSION=$OPTARG;;
	esac
done

# Version number is required to build
if [ ! ${VERSION[@]} ]
	then
		failed "No framework verson supplied"
fi

OUTPUT="ShelfbucksMobileFramework"

# Clean framework directory
rm -rf $OUTPUT
mkdir -p $OUTPUT

# Bump build number and ensure proper framework version number
agvtool new-version -all $VERSION

# Build the framework
xcodebuild -configuration Release clean build || failed "Could not build armv7 framework for release"
xcodebuild -configuration Release -sdk iphoneos clean build || failed "Could not build framework for release"

# Create path for binary
mkdir "${OUTPUT}/Framework"

# Generate the framework binary
lipo -create build/Release-iphoneos/libShelfbucksSDK.a -output ${OUTPUT}/Framework/$FRAMEWORK_FILE_NAME

# Create other folders for Framework release
HEADERS_PATH="${OUTPUT}/Headers"

mkdir "$HEADERS_PATH"

# Move the headers, assets, and docs into place
if [ -e scripts/public-headers.txt ]
  then
    echo found public headeres text
    cat scripts/public-headers.txt | while read line; do
      if [ -e "ShelfbucksSDK/$line" ]
        then
          echo "Copied header $line"
          cp ShelfbucksSDK/$line $HEADERS_PATH
      fi
    done
fi
