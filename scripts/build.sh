FILE=./source/pdxinfo
BUILD_NUMBER=$(grep 'buildNumber=' $FILE | sed 's/[^0-9]*//g')
NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))
sed -i '' "s/buildNumber=$BUILD_NUMBER/buildNumber=$NEW_BUILD_NUMBER/" $FILE
pdc -sdkpath ~/Developer/tools/PlaydateSDK ./source ./build/Lighthouse.pdx
