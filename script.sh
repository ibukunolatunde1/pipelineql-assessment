format_output() {
    if [ $1 -eq 0 ]; then
        # echo "$(jq -n --arg in "$2" --arg st "SAFE" '{image: $in, status: $st}')"
        echo "SAFE"
    else
        # echo "$(jq -n --arg in "$2" --arg st "UNSAFE" '{image: $in, status: $st}')"
        echo "UNSAFE"
    fi
}

result=()
mystring=["ruby:3.1-alpine3.15","node:18-alpine3.15","nginx:1.19.6"]
images=$(echo $mystring | cut -d "[" -f2 | cut -d "]" -f1)
IFS="," read -a IMAGES <<< $images
for i in ${IMAGES[@]}
do
    value=$(trivy image --quiet --ignore-unfixed --severity HIGH,CRITICAL $i | grep -i "Total" | awk '{print $2}')
    values=$(format_output $value)
    result+=("$values")

done

myValue=$(jq -n --arg names "${IMAGES[*]}" --arg value "${result[*]}" '{"name": ($names / " "), "title": ($value / " ")}')
myNewValue=$(echo $myValue | jq '[.name, .title] | transpose | map( {image: .[0],status: .[1]})')
myNewNewValue=$(echo $myNewValue | sed "s/\"/'/g")
myLatestValue=$(jq -n --arg names "$myNewNewValue" '{"body": ($names)}')
echo $myLatestValue > file.json
curl -X POST -H "Accept: application/vnd.github+json" -H "Authorization: token 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" https://api.github.com/repos/ibukunolatunde1/pipelineql-assessment/issues/34/comments -g -d @file.json

