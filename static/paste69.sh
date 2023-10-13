#!/bin/bash
# Paste69 CLI script

PASTE69_URL=${PASTE69_URL:-"https://0x45.st"}

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

# Check for the presence of a clipboard program
cliptools=("xclip" "xsel" "pbcopy")
for tool in "${cliptools[@]}"; do
  if command -v $tool &> /dev/null; then
    case $tool in
      xclip)
        clipboard="xclip -selection clipboard"
        ;;
      xsel)
        clipboard="xsel --clipboard"
        ;;
      pbcopy)
        clipboard="pbcopy"
        ;;
    esac
    break
  fi
done

# Show help text
function show_help {
  echo "Paste69 CLI script"
  echo ""
  echo "Usage:"
  echo "  paste69 <file> [options]"
  echo "  cat <file> | paste69 [options]"
  echo ""
  echo "Options:"
  echo "  -h, --help                 Show this help text."
  echo "  -l, --language <language>  Set the language of the paste."
  echo "  -p, --password <password>  Set a password for the paste. This enables encryption."
  echo "  -x, --burn                 Burn the paste after it is viewed once."
  echo "  -r, --raw                  Return the raw JSON response."
  echo "  -c, --copy                 Copy the paste URL to the clipboard."
}

burn=false
encrypt=false

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
      shift
      shift
      ;;
    -p|--password)
      password="$2"
      shift
      shift
      ;;
    -x|--burn)
      burn=true
      shift
      ;;
    -r|--raw)
      raw=true
      shift
      ;;
    -c|--copy)
      copy=true
      shift
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
if [ -z "$file" ] && ! [ -p /dev/stdin ]; then
  echo "Error: no data or file provided"
  show_help
  exit 1
fi

# Build the URL
url="$PASTE69_URL/api/pastes"

# Make the request
if [ ! -z "$file" ]; then
  contents=$(/usr/bin/cat $file)
else
  data=$(/usr/bin/cat)
  # Check if the data is too large
  if [ ${#data} -gt 10000 ]; then
    echo "Error: stdin input too large. Use a file instead."
    exit 1
  fi
  contents=$data
fi

# If password is set, we need to set the `encrypt` flag
if [ ! -z "$password" ]; then
  encrypt=true
fi

# Create the JSON payload, and then clean it up
json=$(jq -n \
  --arg contents "$contents" \
  --arg extension "$extension" \
  --arg language "$language" \
  --arg password "$password" \
  --argjson encrypt $encrypt \
  --argjson burn $burn \
  '{"contents": $contents, "extension": $extension, "language": $language, "password": $password, "encrypt": $encrypt, "burnAfterReading": $burn}')

response=$(
  curl -s -X POST $url \
    -H "Content-Type: application/json" \
    -d "$json"
)

if [ $? -ne 0 ]; then
  echo "An error occurred while making the request"
  exit 1
fi

# Check if there is an error
error=$(echo $response | jq -r '.error')
if [ "$error" != "null" ]; then
  echo "Error: $error"
  exit 1
fi

# If raw is set, return the raw JSON response
if [ ! -z "$raw" ]; then
  echo $response
  exit 0
fi

# Get the paste URL from the response
paste_url=$(echo $response | jq -r '.url')

# Print the paste URL
echo $paste_url

# If copy is set, copy the paste URL to the clipboard
if [ ! -z "$copy" ]; then
  if [ ! -z "$clipboard" ]; then
    echo $paste_url | $clipboard
  else
    echo "Error: the --copy flag requires a clipboard program to be installed"
    echo "Install one of the following:"
    for tool in "${cliptools[@]}"; do
      echo "  $tool"
    done
    exit 1
  fi
fi