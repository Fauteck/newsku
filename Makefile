docs-build:
	 mkdocs build -f mkdocs/mkdocs.yml -c -d ../docs/documentation
docs-serve:
	mkdocs serve -f mkdocs/mkdocs.yml
