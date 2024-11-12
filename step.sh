#!/bin/bash
set -ex

LICENSE_FILE="ixguard-license.txt"
EXPORT_OPTIONS_PLIST="export_options.plist"
PROTECTED_ARCHIVE="protected.xcarchive"
IXGUARD_GENERATED_FILES_DIRECTORY="ixguard-files"

# Download the license file
if [ -n "${BITRISEIO_IXGUARD_LICENSE_URL}" ]; then
    curl ${BITRISEIO_IXGUARD_LICENSE_URL} -o "$LICENSE_FILE"
else
    echo "Need to import the ixguard license file into Bitrise."
    exit 1
fi

# Download the export options plist file
if [ -n "${BITRISEIO_EXPORT_OPTIONS_URL}" ]; then
    curl ${BITRISEIO_EXPORT_OPTIONS_URL} -o "$EXPORT_OPTIONS_PLIST"
else
    echo "Need to import the export options file into Bitrise."
    exit 1
fi

# Make sure ixguard is installed
if ! command -v ixguard >/dev/null 2>&1; then
    echo "iXGuard must be installed."
    exit 1
fi

# Process the existing xcarchive
ixguard -config "ixguard.yml" -o="$PROTECTED_ARCHIVE" "$BITRISE_XCARCHIVE_PATH"

envman add --key PROTECTED_ARCHIVE --value "$(realpath $PROTECTED_ARCHIVE)"

# Create the output directory
mkdir "$IXGUARD_GENERATED_FILES_DIRECTORY"

# Group and compress the generated files
mv "ixguard-dsymutil.log" "ixguard.log" "mapping.yml" "protectionreport.html" "statistics.yml" "support_files.zip" "telemetry_dump.json" "$IXGUARD_GENERATED_FILES_DIRECTORY/"
cp -r "$PROTECTED_ARCHIVE" "$IXGUARD_GENERATED_FILES_DIRECTORY/"
zip -r "$IXGUARD_GENERATED_FILES_DIRECTORY.zip" "$IXGUARD_GENERATED_FILES_DIRECTORY"

mv "$IXGUARD_GENERATED_FILES_DIRECTORY.zip" "$BITRISE_DEPLOY_DIR/"
exit 0
