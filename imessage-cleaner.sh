#! /bin/bash

print_usage() {
  echo -e "Usage: imessage-cleaner.sh [--no-backup] -a attachment-dir -e extension1 -e extension2 ...\n"
  echo -e "\t-a, --attachments-directory dir:"
  echo -e "\t\tiMessage attachment directory absolute path."
  echo -e "\t\tTypically in \"/User/<username>/Library/Messages/Attachments\""
  echo -e "\t-e, --extension ext:"
  echo -e "\t\tExtension of files to remove. Ex: -e gif"
  echo -e "\t--no-backup:"
  echo -e "\t\tDon't create an archive of removed files."
}

print_error() {
  echo "ERROR: $1"
}

# Parse arguments
POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
  -h | --help)
    print_usage
    exit 0
    ;;
  -a | --attachments-directory)
    ATTACH_DIR="$2"
    shift # past argument
    shift # past value
    ;;
  -e | --extension)
    EXTS+=("$2")
    shift # past argument
    shift # past value
    ;;
  --no-backup)
    NO_BACKUP="true"
    shift # past argument
    ;;
  *)                   # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift              # past argument
    ;;
  esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# Verify attachments directory set
if [ -z ${ATTACH_DIR+x} ]; then
  print_error "Attachment directory not set"
  print_usage
  exit 1
fi

# Need at least one extension
if [ ${#EXTS[@]} -eq 0 ]; then
  print_error "No extensions listed"
  print_usage
  exit 1
fi

# Create a backup archive
if [ ! -z ${NO_BACKUP+x} ]; then
  echo "Are you sure you don't want to back up your attachments?"
  read VERIFY
  if [ "${VERIFY}" != "y" ] && [ "${VERIFY}" != "Y" ]; then
    echo "Cancelling job."
    exit 1
  fi
fi

if [ ! -d "${ATTACH_DIR}" ]; then
  print_error "Attachment directory \"${ATTACH_DIR}\" does not exist."
  exit 1
fi

DATE_AND_TIME=$(date +"%Y-%m-%d_%H-%M-%S")

FIND_ARGS=""
for EXT in ${EXTS[@]}; do
  if [[ ! -z "${FIND_ARGS}" ]]; then
    FIND_ARGS+=" -o "
  fi
  FIND_ARGS+=" -type f -name \"*.${EXT}\""
done

FIND_OUTPUT_FILE="matches_${DATE_AND_TIME}.txt"

FIND_COMMAND="find ${ATTACH_DIR} ${FIND_ARGS} > ${FIND_OUTPUT_FILE}"
echo $FIND_COMMAND
eval $FIND_COMMAND

if [ -z ${NO_BACKUP+x} ]; then
  TAR_COMMAND="tar cvzf files_${DATE_AND_TIME}.tar.gz -T ${FIND_OUTPUT_FILE}"
  echo $TAR_COMMAND
  eval $TAR_COMMAND
  TAR_STATUS=$?

  if [ ! $TAR_STATUS -eq 0 ]; then
    print_error "tar failed to create backups. Not removing files"
    exit 1
  fi
fi

for f in $(cat ${FIND_OUTPUT_FILE}); do
  mv "$f" ~/.Trash
done
