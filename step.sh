#!/bin/bash
set -e

LICENSE_FILE="ixguard-license.txt"
PROTECTED_ARCHIVE="protected.xcarchive"
IXGUARD_GENERATED_FILES_DIRECTORY="ixguard-files"

# Download licenses
if [ -n "${BITRISEIO_IXGUARD_LICENSE_URL}" ]; then
    curl ${BITRISEIO_IXGUARD_LICENSE_URL} -o "$LICENSE_FILE"
else
    echo "Need to import the ixguard license file into Bitrise."
    exit 1
fi

# Make sure ixguard is installed
if ! command -v ixguard >/dev/null 2>&1; then
    echo "iXGuard must first be installed."
    exit 1
fi

# Process the unprotected xcarchive
ixguard -config "ixguard.yml" -o="$PROTECTED_ARCHIVE" "$BITRISE_XCARCHIVE_PATH"

# Make the protected archive available from outside this Step
envman add --key PROTECTED_ARCHIVE --value "$(realpath $PROTECTED_ARCHIVE)"

# Group and compress the generated files
mkdir "$IXGUARD_GENERATED_FILES_DIRECTORY"
mv "ixguard-dsymutil.log" "ixguard.log" "mapping.yml" "protectionreport.html" "statistics.yml" "support_files.zip" "telemetry_dump.json" "$IXGUARD_GENERATED_FILES_DIRECTORY/"
cp -r "$PROTECTED_ARCHIVE" "$IXGUARD_GENERATED_FILES_DIRECTORY/"
zip -r "$IXGUARD_GENERATED_FILES_DIRECTORY.zip" "$IXGUARD_GENERATED_FILES_DIRECTORY"

mv "$IXGUARD_GENERATED_FILES_DIRECTORY.zip" "$BITRISE_DEPLOY_DIR/"
exit 0
