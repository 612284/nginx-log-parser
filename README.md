# This is an Nginx log file parser
It can convert a log file into CSV format. It can also output the filtered result by response code, request IP, the request method, or request URL.


### To run parser, follow these steps:

1. install  git, curl, awk

2. clone this repository
```
git clone https://github.com/612284/nginx-log-parser.git
```
3. enter your values in the environment section of the start.sh file
It makes sense to fill in the last three lines if you want to see the result of the script on GitHub.
```
LOGFILE="./nginx.log" //path to logfile
LINES=10000           //number of lines displayed by default
GH_TOKEN="ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" //GitHub token
GH_REPO="my-repo-for-parse-log-nginx"   //desire GitHub repository name
GH_USER="USER"    //GitHub user name

```
Also, if you want to see the result of the script on GitHub, you need to uncomment the last three lines of this script and have a GitHub account with SSH access.
```
# create_gh_repo_if_not_exist
# cd output/
# git push -u origin main
```
4. add execution permissions to script start.sh
```
chmod a+x start.sh
```
5. run
- The script can be run without arguments and the result will be the conversion of the log file to csv.
```
bash start.sh
```
- A script run with -r=200 or --response=200 will output lines with response code 200.
- A script run with -l=10 or --lines=10 will output first 10 lines.
- A script run with the parameters -s=ip or --sort=ip will output the number of requests from  each ips.
- A script run with the parameters -s=m or --sort=m will output the number of requests for each methods.
- A script run with the parameters -s=r or --sort=r will output the number of requests for each pages.

Example:
```
bash start.sh -r=200 -l=10 -s=r
```
The first column is the number of requests, sorted from largest to smallest. The second column is the query page. The output contains the first 10 lines. 
![](img/output1.png)

The number of arguments can be from 0 to 3. The order of the parameters does not matter.
