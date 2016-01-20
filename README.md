# dublincore2csl-yaml
Simple Perl script to produce CSL YAML from DublinCore metadata in HTML page.

## Example

Running `./dublincore2csl-yaml.pl https://otik.uk.zcu.cz/handle/11025/7268` produces following output:

~~~{.yaml}
---
- URL: https://otik.uk.zcu.cz/handle/11025/7268
  accessed:
    date-parts:
      -
        - 2016
        - 1
        - 20
  author:
    - family: Dolejš
      given: Michal
  genre: Diplomová práce
  id: dolejš2013
  issued:
    date-parts:
      -
        - 2013
        - 9
        - 4
  keyword: 'Sýrie, Irák, iráčtí uprchlíci, migrace, Irácká svoboda, Arabské jaro, Syria, Iraq, Iraqi refugees, migration, Iraqi Freedom, Arab spring'
  publisher: Západočeská univerzita v Plzni
  title: Sýrie a socioekonomické dopady irácké imigrace
  type: thesis

...
~~~
