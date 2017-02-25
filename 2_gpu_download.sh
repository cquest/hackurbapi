urls=$(jq -r .[].document.archiveUrl gpu.json)
mkdir -p gpu_data
cd gpu_data
for url in $urls
do
  wget -nc $url
  f=$(echo $url | sed 's!.*/!!')
  # on ne garde par les PDF (parfois zippés)
  zip $f -d '*.pdf'
  zip $f -d '*/Pieces_ecrites.zip'
  unzip -u $f
done
rm */Pieces_ecrites.zip
