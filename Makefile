.PHONY : coverage
coverage :
	rm -f `find . -name 'bisect*.out'`
	BISECT_ENABLE=YES dune runtest --force
	bisect-ppx-report -I _build/default/ -html _coverage/ \
		`find . -name 'bisect*.out'`
