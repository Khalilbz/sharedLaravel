#!/bin/sh
die () {
    echo >&2 "$@"
    exit 1
}
log () {
    echo "  -> $@"
}
getinput () {
    RESET="\033[0m"
    BOLD="\033[1m"
    YELLOW="\033[38;5;11m"
    #echo -e "I ${RED}love${NC} Stack Overflow";
    #printf  '^[[31mkiloi^[[m' "koloi $1";
    read -p "$(echo $BOLD$YELLOW"$1 "$RESET) [$(echo $BOLD"$2"$RESET)]: " name;
    name=${name:-$2}
    echo $name
}
info () {
    RESET="\033[0m"
    BOLD="\033[1m"
    COLOR="\033[38;5;6m"
    echo $BOLD$COLOR"$1 "$RESET
}
danger () {
    RESET="\033[0m"
    BOLD="\033[1m"
    COLOR="\033[38;5;1m"
    echo $BOLD$COLOR"$1 "$RESET
}
data () {
    RESET="\033[0m"
    BOLD="\033[1m"
    COLOR="\033[38;5;7m"
    echo $BOLD$COLOR"$1 "$RESET
}
waitme () {
    printf  '\e[1;32m%-6s\e[m' "$1"
    printf "\n"
    read -p "(Press any key to continue)" x
}
clearterminal () {
    echo ""
    read -p "(Press any key to continue)" x
    clear
}

#info "testina"
#TEST project="$(getinput 'Project Name' 'MyProject')"
#TEST a="$(getinput 'Project a' 'aaaaaa')"
#TEST echo $project hello guys $a
#TEST exit 1

clear
echo "";
info "Welcome, This tool helps you converts your laravel project to a shared host project for production";
danger "This tool should work in the parent folder of your project's folder";
danger "EXP: if your project is '/home/user/laravelProject'"
danger "     You have to be in '/home/user'"
echo "";

#TEST [ "$#" -eq 2 ] || die "2 argument required, $# provided"

# Creating Directories
uploadDir="$(getinput 'The result Folder Name (To be uploaded)' 'upload')"
wDir="$(getinput 'The public Folder (On the Server)' 'www')"
if [ -d "$uploadDir" ]; then
    rm -R $uploadDir
    log $uploadDir " Deleted";
fi

mkdir $uploadDir
mkdir $uploadDir/applications
mkdir $uploadDir/$wDir
log "Directories Created";

# Copy app folder
devDir="$(getinput 'Your Laravel Project Dir (Current Folder Name)' 'project')"
cp -R $devDir $uploadDir/applications/$devDir
log "'"$devDir"'Copied inside '"$uploadDir"'";

clearterminal

# DB informations
    cp $uploadDir/applications/$devDir/.env.example $uploadDir/applications/$devDir/.env
if [ ! -f "$uploadDir/applications/$devDir/.env" ]; then
    log "'.env' file is genereted from '.env.example'";
fi
waitme "Now you will update your DB informations with nano 'CTRL+X to save file & exit'"
nano $uploadDir/applications/$devDir/.env
echo "Good Job"
clearterminal

# Changes on Bootstrap/app.php
info "Copy this function to Add it to 'bootstrap/app.php' to return the public path"
info "change USERNAME_HERE with your server's user name"
data "  \$app->bind('path.public', function ()"
data "  {"
data "  return '/home/USERNAME_HERE/$wDir/$devDir';"
data "  });"
echo ""
waitme "Now you will update the 'app.php' with nano 'CTRL+X to save file & exit'"
nano $uploadDir/applications/$devDir/bootstrap/app.php
echo "Good Job"
clearterminal

# Changes on config/app.php
info "For Production mode you have to update these params inside your App Config"
data "  change 'APP_ENV' to 'production'"
data "  change 'APP_DEBUG' to 'false'"
data "  change 'APP_URL' to your website URL"
echo ""
waitme "Now you will update the 'config/app.php' with nano 'CTRL+X to save file & exit'"
nano $uploadDir/applications/$devDir/config/app.php
echo "Good Job"
clearterminal

# Coping public folder to www
cp -R $uploadDir/applications/$devDir/public $uploadDir/$wDir/$devDir
log "Public folder copied to '"$uploadDir/$wDir/$devDir"'"

# Creating .htaccess file inside www
htaccess="$uploadDir/$wDir/.htaccess"
touch $htaccess
echo "# Change website.com to your domain name" >> $htaccess
echo "RewriteEngine on" >> $htaccess
echo "#RewriteCond %{HTTP_HOST} ^www.website.com [NC]" >> $htaccess
echo "#RewriteRule ^(.*)$ http://website.com/$1 [L,R=301]" >> $htaccess
echo "#RewriteCond %{HTTP_HOST} ^(www.)?website.com$" >> $htaccess
echo "RewriteCond %{REQUEST_URI} !^/"$devDir"/" >> $htaccess
echo "RewriteCond %{REQUEST_FILENAME} !-f" >> $htaccess
echo "RewriteCond %{REQUEST_FILENAME} !-d" >> $htaccess
echo "RewriteRule ^(.*)$ /"$devDir"/\$1" >> $htaccess
echo "#RewriteCond %{HTTP_HOST} ^(www.)?website.com$" >> $htaccess
echo "RewriteRule ^(/)?$ "$devDir"/index.php [L]" >> $htaccess
log "'.htaccess' file is generated for you in '"$htaccess"'"
info "If you want to redirect your website traffic from www.website.com to website.com please go to "$htaccess" and uncomment the commented rules"
clearterminal

# Changes on index.php
info "Copy these paths to change them in '$uploadDir/$wDir/$devDir/index.php'"
data ">change the paths of 'autoload.php' and 'app.php' to :"
data "__DIR__.'/../../applications/"$devDir"/vendor/autoload.php'"
data "__DIR__.'/../../applications/"$devDir"/bootstrap/app.php'"
echo ""
waitme "Now you will update the '$uploadDir/$wDir/$devDir/index.php' with nano 'CTRL+X to save file & exit'"
nano $uploadDir/$wDir/$devDir/index.php
echo "Good Job"
clearterminal

# Alert about php.ini
danger "This step is optional you can ignore it by pressing any key"
info "Make sure to check these changes in your server's 'php.ini'"
data "    error_reporting  =  E_ALL"
data "    display_errors = Off"
data "    display_startup_errors = Off"
data "    log_errors = On"
data "    #---------------------------"
data "    post_max_size = 110M"
data "    #---------------------------"
data "    file_uploads = On"
data "    #---------------------------"
data "    upload_max_filesize = 100M"
echo ""
info "Make sure to check these changes in your server's 'apache2.conf'"
data "<Directory /var/www/>"
data "        Options Indexes FollowSymLinks"
data "        AllowOverride All"
data "        Require all granted"
data "</Directory>"
echo ""
echo ""
info "<<  Finally All modifications are done ^_^ Enjoy your Project  >>"
clearterminal


















