all: 800-53v4v5merged.txt 800-53v4v5diffed.txt 800-53rev5ipd.txt ../V5Controls.txt

800-53v4v5merged.txt: 800-53rev4.txt 800-53rev5ipd.txt classify.pl
	cat 800-53rev5ipd.txt 800-53rev4.txt | perl classify.pl | sort -t: | cut -d: -f2- > 800-53v4v5merged.txt

800-53rev5ipd.txt: ../V5Controls.txt append.pl
	perl append.pl ":v5ipd" ../V5Controls.txt > 800-53rev5ipd.txt

../V5Controls.txt: parse-v5.pl sp800-53r5-draft.xml
	perl parse-v5.pl sp800-53r5-draft.xml > ../V5Controls.txt

800-53v4v5diffed.txt: 800-53rev4.txt 800-53rev5ipd.txt classify.pl
	cat 800-53rev5ipd.txt 800-53rev4.txt | perl classify.pl | perl revdiff.pl | sed 's/<\/del><del>//g; s/<\/ins><ins>//g;' > 800-53v4v5diffed.txt

