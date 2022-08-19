IMAGES=${{ github.event.issue.body }}

for i in ${IMAGES[@]}
do
    echo $i
done

echo "All done"