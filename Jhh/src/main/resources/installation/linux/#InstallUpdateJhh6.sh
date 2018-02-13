#! /bin/bash
# Installation and update for program JHH6 (c) 2018 cwkuehl.de

function download {
  curl -o ./temp/jhh6.zip 'http://cwkuehl.de/wp-content/uploads/2018/02/Jhh-6_0.zip'
  rm -rf temp/zip
  unzip ./temp/jhh6.zip -d ./temp/zip
  cp -rf ./temp/zip/* .
  rm -rf temp/zip
  rm ./temp/jhh6.zip
}

if test ! -d temp
then
  mkdir temp
fi

if test -e Jhh-1.0.jar
then
  download
  rm ./Leer*.*
else
  download
fi

if test ! -e log4j.properties
then
  cp Leerlog4j.properties log4j.properties
fi

if test ! -e ServerConfig.properties
then
  cp LeerServerConfig.properties ServerConfig.properties
fi

if test ! -d ~/hsqldb
then
  mkdir ~/hsqldb
fi

if test ! -d ~/hsqldb/JHH6.properties
then
  cp LeerJHH6.properties ~/hsqldb/JHH6.properties
  cp LeerJHH6.script ~/hsqldb/JHH6.script
fi

chmod +x ./#JHH6.sh

rm -f *.cmd
rm -f *.exe

# Start JHH6
./#JHH6.sh
