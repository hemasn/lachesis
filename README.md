Lachesis
====

~~~ {.bash}
lachesis.r -c FILENAME -a FILENAME -e FILENAME -l FILENAME [-o FILENAME]
~~~

Generates a roster that assigns assessors to cases in an exam matrix
and timetables candidates to cycle between assessors at a venue.

Valid filetypes are csv, xls and xlsx.

  `--candidates` `-c` Spreadsheet with candidate info.

  `--assessors`  `-a` Spreadsheet with assessor info.

  `--exams`      `-e` Spreadsheet with exam matrix info.

  `--locations`  `-l` Spreadsheet with venue info.

  `--outfile`    `-o` Spreadsheet for storing final master roster.

  `--help`       `-h` Print this usage information.

If `--outfile` is not given, will output to stdout.
