set -e
xcodebuild -alltargets clean
xcodebuild -scheme Framework -configuration Release build -derivedDataPath build_results
