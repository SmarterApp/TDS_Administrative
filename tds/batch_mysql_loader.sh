#!/bin/bash
curr_dir=$PWD

TDS_MYSQL_HOST=[enter tds mysql host]
TDS_MYSQL_PORT=[enter tds mysql port]
TDS_MYSQL_USER=[enter tds mysql user]
TDS_MYSQL_PASSWORD=[enter tds mysql password]

for f in "$@";
do
  abs_path=$(readlink -f "$f")
  xml_blob=$(cat "$abs_path")
  # echo "mysql -h $TDS_MYSQL_HOST -P $TDS_MYSQL_PORT -u $TDS_MYSQL_USER -p$TDS_MYSQL_PASSWORD -e \"call itembank.loader_main('$xml_blob')\""
  mysql -h $TDS_MYSQL_HOST -P $TDS_MYSQL_PORT -u $TDS_MYSQL_USER -p$TDS_MYSQL_PASSWORD -e "call itembank.loader_main('$xml_blob')"
  echo "Finished loading $abs_path to itembank."
done
