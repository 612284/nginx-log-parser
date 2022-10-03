#!/bin/bash

# ----------- environment --------------------------

LOGFILE="./nginx.log"
LINES=10000
GH_TOKEN="ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
GH_REPO="my-repo-for-parse-log-nginx" 
GH_USER="USER"

# ------------- functions --------------------------
filter_response_code(){
if [[ $RESPONSE_CODE ]]; then
grep ",$RESPONSE_CODE,"
fi
}

filter_sort(){
if  [[ $SORT == "ip" ]]; then get_request_ips | to_csv;
elif [[ $SORT == "r" ]]; then get_request_pages | to_csv;
elif [[ $SORT == "m" ]]; then get_request_methods | to_csv;
else echo "wrong argument"; exit 1;
fi
}

filter_trash(){
grep -v "\/rss\/" \
| grep -v robots.txt \
| grep -v "\.css" \
| grep -v "\.jss*" \
| grep -v "\.png" \
| grep -v "\.ico"
}

sort_desc(){
 sort -rn
}

wordcount(){
 sort \
 | uniq -c
}

request_method(){
awk -F ',' '{print $3}'
}

request_ips(){
awk -F ',' '{print $1}'
}

request_pages(){
awk -F ',' '{print $4}'
}

return_kv(){
awk -F ',' '{print $1, $2}'
}

return_top_lines(){
head -$LINES
}

to_csv(){
sed 's/\ /,/g' \
| sed 's/,*//' \
| sed 's/,$//'
}

convert_to_csv(){
while IFS= read -r line; do
  var1=$( echo $line |sed 's/\"//g' | awk '{ print $1","$4,$5","$6","$7","$8","$9","$10","$11 }' )
  var2=$( echo $line |sed 's/,//g' | awk -F '\"' '{print $6}')
  var3=$( echo $line | awk '{ print $(NF-4)","$(NF-3)","$(NF-2)","$(NF-1)","$(NF) }')
printf '%s\n' "$var1"",""$var2"",""$var3"
done
}

add_to_git(){
cd ./output/
if [ ! -d ".git" ]; then
  git init
fi
git add nginx.log.csv
git commit -m "update file" nginx.log.csv
cd ..
}

create_gh_repo_if_not_exist(){
R=$(curl -s -o /dev/null -I -w "%{http_code}" https://api.github.com/repos/$GH_USER/$GH_REPO)
if  [ $R == 404 ]; then
  curl \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GH_TOKEN" \
    -d '{"name": "'$GH_REPO'"}' \
    https://api.github.com/user/repos
  cd output/
  git branch -M main
  git remote add origin git@github.com:$GH_USER/$GH_REPO.git
  cd ..
fi
}

get_request_ips(){
 filter_trash \
| request_ips \
| wordcount \
| sort_desc \
| return_kv \
| return_top_lines
}

get_request_methods(){
 filter_trash \
| request_method \
| wordcount \
| return_kv
}

get_request_pages(){
 filter_trash \
| request_pages \
| wordcount \
| sort_desc \
| return_kv \
| return_top_lines
}

output_with_filters(){
convert_to_csv \
| if [[ -n $RESPONSE_CODE ]] && [[ -n $SORT ]] ; then filter_response_code | filter_sort;
elif [[ -n $RESPONSE_CODE ]] && [[ -z $SORT ]] ; then filter_response_code | return_top_lines;
else filter_sort;
fi
}

# ------------run the script here---------------------

mkdir -p ./output

if [ $# -eq 0 ]; then
  cat $LOGFILE \
  | convert_to_csv > ./output/nginx.log.csv
else
  for i in "$@"; do
    case $i in
      -r=*|--response=*)
        RESPONSE_CODE="${i#*=}"
        shift
        ;;
      -s=*|--sort=*)
        SORT="${i#*=}"
        shift
        ;;
      -l=*|--lines=*)
        LINES="${l#*=}"
        shift
        ;;
      -*|--*)
        echo "Unknown option $i"
        exit 1
        ;;
      *)
        ;;
    esac
  done
  cat $LOGFILE \
  |output_with_filters > ./output/nginx.log.csv
fi
add_to_git
# ------------------------------------------------------
# uncomment the following lines if you will be using the GitHub repository

# create_gh_repo_if_not_exist
# cd output/
# git push -u origin main
