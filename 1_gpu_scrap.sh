psql -Atc "select insee from insee_cog_2015;" | \
	parallel -j 8 \
		wget -q -nc "https://www.geoportail-urbanisme.gouv.fr/document/info/?partition=DU_{}" -O {}.json

: > gpu.sjson; for f in *.json; do insee=$(echo $f |sed 's/.json//'); sed "s/\"success\"/\"insee\":\"$insee\", \"success\"/" $f >> gpu.sjson; done

jq -sc '.' gpu.sjson > gpu.json

