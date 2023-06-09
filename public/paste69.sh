#!/bin/bash
# Paste69 CLI script

# Check if `curl` is installed
if ! command -v curl &> /dev/null; then
  echo "Error: curl is not installed"
  exit 1
fi

# Check if `jq` is installed
if ! command -v jq &> /dev/null; then
  echo "Error: jq is not installed"
  exit 1
fi

# Show help text
function show_help {
  echo "Usage:"
  echo "  paste69 <file> [options]"
  echo "Options:"
  echo "  -h, --help                 Show this help text"
  echo "  -l, --language <language>  Set the language of the paste. If a file is provided, the language will be automatically detected."
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -h|--help)
      show_help
      exit 0
      ;;
    -l|--language)
      language="$2"
      shift 2
      ;;
    *)
      if [ -z "$file" ]; then
        file=$1
        extension="${file##*.}"
      else
        echo "Error: too many arguments"
        show_help
        exit 1
      fi
      shift
      ;;
  esac
done

# Check if data or a file was provided, otherwise error out
if [ -z "$file" ] && [ -z "$data" ]; then
  echo "Error: no data or file provided"
  show_help
  exit 1
fi

# Build the URL
url="https://0x45.st/api/v1/paste"
if [ ! -z "$language" ]; then
  url="$url?language=$language"
elif [ ! -z "$extension" ]; then
  url="$url?extension=$extension"
fi

# Make the request
if [ ! -z "$file" ]; then
  response=$(curl -s -X POST -H "Content-Type: text/plain" --data-binary "@$file" $url)
else
  # Check if the data is too large
  if [ ${#data} -gt 10000 ]; then
    echo "Error: stdin input too large. Use a file instead."
    exit 1
  fi
  response=$(curl -s -X POST -H "Content-Type: text/plain" -d "$data" $url)
fi

if [ $? -ne 0 ]; then
  echo "An error occurred while making the request"
  exit 1
fi

# Check if `success` is true
if [ $(echo $response | jq -r '.success') != "true" ]; then
  echo "Error: $(echo $response | jq -r '.error')"
  exit 1
fi

# Print links
link=$(echo $response | jq -r '.paste.link')
delete_link=$(echo $response | jq -r '.paste.delete_link')

echo "Link: $link"
echo "Raw link: $link?raw"
echo "Delete link: $delete_link"