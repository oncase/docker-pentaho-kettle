#!/bin/bash

awsfile="/home/pentaho/.aws/credentials"
kettlefile="/home/pentaho/.kettle/kettle.properties"
jndifile="/pentaho/data-integration/simple-jndi/jdbc.properties"
rm -f "$awsfile" "$kettlefile" "$jndifile"
touch "$awsfile" "$kettlefile" "$jndifile"

echo "[default]" >> "$awsfile"

while IFS='=' read -r -d '' n v; do
    if [[ $n == _JNDI_* ]] ;
    then
      key="${n/_JNDI_/}"
      key="${key/_type/\/type}"
      key="${key/_driver/\/driver}"
      key="${key/_url/\/url}"
      key="${key/_user/\/user}"
      key="${key/_password/\/password}"
      echo "$key=$v" >> "$jndifile"
    fi

    if [[ $n == _ENV_* ]] ;
    then
      key="${n/_ENV_/}"
      echo "$key=$v" >> "$kettlefile"
      echo "PATH='$PATH'" >> "$kettlefile"
    fi

    if [[ $n == _AWS_* ]] ;
    then
      key="${n/_AWS_/}"
      echo "$key=$v" >> "$awsfile"
    fi

done < <(env -0)
