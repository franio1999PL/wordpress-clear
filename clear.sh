#!/bin/bash

PHP_VERSION="php"
CURR_PATH=`pwd`
RED='\033[0;31m'
NC='\033[0m' # No Color

KROK=0

files_from_main_folder_to_remove=(
    index.php
    wp-activate.php
    wp-blog-header.php
    wp-comments-post.php
    wp-config-sample.php
    wp-cron.php
    wp-links-opml.php
    wp-load.php
    wp-login.php
    wp-mail.php
    wp-settings.php
    wp-signup.php
    wp-trackback.php
    xmlrpc.php
    readme.html
    license.txt
)

if ! [ -x "$(command -v wp)" ]; then
    echo "wp could not be found"
    curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -s --output $CURR_PATH/wp
    chmod +x -v $CURR_PATH/wp
    wp_path="php $CURR_PATH/wp"
else
    echo "wp cli was installed"
    wp_path=`which wp`
fi

    log_file=$CURR_PATH/usuwanie_wirusow.log
    echo "Rozpoczynam usuwanie wirusow" > $log_file;
    date >> $log_file;
    
echo -e "${RED} KROK $((++KROK))${NC}: resetuje uprawnienia plików oraz folderów"; 
    find . -type d -exec chmod 755 {} \;  
    find . -type f -exec chmod 644 {} \;  
        echo "resetuje uprawnienia plików oraz folderów" >> $log_file;
    
echo -e "${RED} KROK $((++KROK))${NC}: usuwam wszystkie pliki, które będą odświeżone przez czystą instalacje"; 
    for plik_do_usuniecia in ${files_from_main_folder_to_remove[@]}; do
        rm -rf $plik_do_usuniecia
        echo "Usuwam $plik_do_usuniecia" >> $log_file;
    done

echo -e "${RED} KROK $((++KROK))${NC}: sprawdź zawartość wp-config.php";
    while true; do

    read -p "Sprawdziłeś plik wp-config.php? (y/n) " yn

    case $yn in 
        [yY] ) echo 'ok, lecimy dalej';
            break;;
        [nN] ) echo 'no weź sprawdź'
            break;;
        * ) echo invalid response;;
    esac

    done
    echo "Sprawdzono plik wp-config.php" >> $log_file;

echo -e "${RED} KROK $((++KROK))${NC}: sprawdzamy pliki poza głównymi plikami wp";

    for file in `find -maxdepth 1 -type f ! -name 'wp-config.php' ! -name 'usuwanie_wirusow.log' ! -name '.htaccess' ! -name 'cleaner.sh' ! -name 'wp' `;do 
        while true; do

            read -p "Czy chcesz usunąć plik $file? (y/n) " yn

            case $yn in 
                [yY] ) echo 'usuwam '; rm -rf $file; echo "Usunięto $file" >> $log_file;
                    break;;
                [nN] ) echo 'Zostawiam plik'
                    break;;
                * ) echo invalid response;;
            esac
        done

    done

echo -e "${RED} KROK $((++KROK))${NC}: usuwam wp-admin wp-includes";
    rm -rf wp-admin wp-includes
    echo "Usunięto foldery wp-admin wp-includes" >> $log_file 

echo -e "${RED} KROK $((++KROK))${NC}: sprawdzamy foldery poza głównymi folderami wp";

    for folder in `find -maxdepth 1 -type d ! -name 'wp-content' | sed -r '/^\.$/d' `;do 
        while true; do

            read -p "Czy chcesz usunąć folder $folder? (y/n) " yn

            case $yn in 
                [yY] ) echo 'usuwam '; rm -rf $folder;  echo "Usuwam folder $folder" >> $log_file; 
                    break;;
                [nN] ) echo 'Zostawiam folder '
                    break;;
                * ) echo invalid response;;
            esac
        done

    done
    
echo -e "${RED} KROK $((++KROK))${NC}: wgrywam świeże pliki wordpress";    
    $wp_path core download --force --skip-content --locale=pl_PL
    echo "Wgrywam świeże pliki wordpress" >> $log_file;
    
echo -e "${RED} KROK $((++KROK))${NC}: aktualizuje wszystkie pluginy";
    echo "Rozpoczynam aktualizację wszystkich pluginów" >> $log_file;
    $wp_path plugin install $($wp_path plugin list --field=name) --skip-plugins --skip-themes --force >> $log_file; 
    echo "Aktualizuje wszystkie pluginy" >> $log_file;

echo -e "${RED} KROK $((++KROK))${NC}: włączam auto update";
    $wp_path plugin auto-updates enable $($wp_path plugin list --field=name) --skip-plugins --skip-themes >> $log_file; 
    echo "włączam auto aktualizacje do wszystkich pluginów" >> $log_file;
    
echo -e "${RED} KROK $((++KROK))${NC}: aktualizuje wszystkie szablony"; 
    $wp_path theme update --all --skip-plugins --skip-themes >> $log_file; 
    echo "aktualizuje wszystkie szablony" >> $log_file;
    
echo -e "${RED} KROK $((++KROK))${NC}: instaluje wordfence"; 
    $wp_path plugin install wordfence --activate --skip-plugins --skip-theme
    echo "Instaluje WordFence" >> $log_file;
    
echo -e "${RED} KROK $((++KROK))${NC}: usuwam wszystki pliki *.php w wp-content/uploads/";
    find wp-content/uploads/ -type f -iname '*.php' -delete
    echo "usuwam wszystki pliki *.php w wp-content/uploads/" >> $log_file;
    
echo -e "${RED} KROK $((++KROK))${NC}: usuwam wszystki pliki *.php.VIRUS w wp-content/uploads/";
    find wp-content/uploads/ -type f -iname '*.php.VIRUS' -delete
    echo "usuwam wszystki pliki *.php.VIRUS w wp-content/uploads/" >> $log_file;

echo -e "${RED} KROK $((++KROK))${NC}: Sprawdzamy konta wszystkich administratorów";
    $wp_path user list --role=administrator --skip-plugins --skip-theme
    for user in `$wp_path user list --field=ID --role=administrator --skip-plugins --skip-themes`
    do 
        while true; do
                user_email=`$wp_path user get $user --field=user_email --skip-plugins --skip-themes`
                echo "Posty użytkownika $user_email"
                $wp_path post list --post_type=page,post --fields=post_title,post_type --author=$user 
                read -p "Czy chcesz usunąć użytkownika $user_email? (y/n) " yn
                
                case $yn in 
                    [yY] ) echo "usuwam użytkownika $user_email. W kolejnym kroku będzie trzeba podać ID użytkownika, któremu przypiszemy posty"; $wp_path user delete $user --prompt=reassign; 
                        break;;
                    [nN] ) echo "zostawiamy użytkownika $user_email";
                        break;;
                    * ) echo invalid response;;
                esac
            done
    done
    echo "Sprawdzamy konta wszystkich administratorów, usunięcie lewych - login cyberfolks" >> $log_file;

echo -e "${RED} KROK $((++KROK))${NC}: reset wszystkich haseł administratorów";
    $wp_path config shuffle-salts
    $wp_path user reset-password $($wp_path user list --role=administrator --field=ID)
    echo "reset wszystkich haseł administratorów" >> $log_file;
    
echo -e "${RED} KROK $((++KROK))${NC}: tworze konto administratora - login fsikora";
    $wp_path user create fsikora sikorafranek@proton.me --role=administrator --skip-plugins --skip-themes
    echo "tworze konto administratora - login cyberfolks" >> $log_file;
        
echo -e "${RED} KROK $((++KROK))${NC}: przywrócenie .htaccess do fabrycznego stanu";
    mv $CURR_PATH/.htaccess $CURR_PATH/.htaccess.old
    $wp_path rewrite flush --hard --skip-plugins --skip-themes
    cat <<EOF >> $CURR_PATH/.htaccess
    
#SecurityCyberFolks

Options All -Indexes

# Deny access to wp-config.php file
<files wp-config.php>
order allow,deny
deny from all
</files>

# Deny access to all .htaccess files
<files ~ "^.*\.([Hh][Tt][Aa])">
order allow,deny
deny from all
satisfy all
</files>

#hide debug.log
<IfModule mod_rewrite.c>
        RewriteEngine On
        RewriteCond %{REQUEST_URI} ^/?wp\-content/+debug\.log$
        RewriteRule .* - [F,L,NC]
</IfModule>
<IfModule !mod_rewrite.c>
    <Files "debug.log">
    <IfModule mod_authz_core.c>
        Require all denied
    </IfModule>
    <IfModule !mod_authz_core.c>
        Order deny,allow
        Deny from all
    </IfModule>
    </Files>
</IfModule>

#SecurityCyberFolks

# BEGIN WordPress
RewriteEngine On
RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
# END WordPress
EOF

    mv $CURR_PATH/wp-content/uploads/.htaccess $CURR_PATH/wp-content/uploads/.htaccess.old
    cat <<EOF >> $CURR_PATH/wp-content/uploads/.htaccess
# Block executables
<FilesMatch "\.(php|phtml|php3|php4|php5|pl|py|jsp|asp|html|htm|shtml|sh|cgi|suspected)$">
 deny from all
</FilesMatch>
EOF

    echo "Zmiana nazwy .htaccess na .htaccess.old" >> $log_file;
    echo "Wgranie czystego pliku .htaccess" >> $log_file;

echo -e "${RED} KROK $((++KROK))${NC}: sprawdzamy inne pliki .htaccess" >> $log_file;

find -mindepth 2 -mtime +25 -name .htaccess  -exec stat -c '%s %n' {} \; | sort -n | awk 'BEGIN { i=0 } i != $1 { i=$1; print}' | while read -r size name
do
    echo "Wyswietlam przykładowy plik $name"
    echo -e "----------------------------------------------------------------"
    cat $name
    echo -e "\n----------------------------------------------------------------" 
    
        read -u 2 -p  "Czy chcesz usunąć pliki takie same jak $name? (y/n). " yn
        ilosc_plikow=`find -name .htaccess -size "$size"c| wc -l`
        case $yn in 
            [yY] ) echo "usuwam pliki podobne do $name / ilosc plikow $ilosc_plikow" >> $log_file; find -name .htaccess -size "$size"c -delete; 
                continue;;
            [nN] ) echo "Zostawiam plik $name" >> $log_file;
                continue;;
            * ) echo invalid response;;
        esac
done


echo -e "${RED} KROK $((++KROK))${NC}: sprawdzenie czy jest mu-plugins"
    if [ -d $CURR_PATH/wp-content/mu-plugins/ ];
    then
        echo "Folder mu-plugins istnieje - sprawdź jego zawartość"
        echo "Sprawdzono zawartość mu-plugins" >> $log_file;
    fi

echo -e "${RED} KROK $((++KROK))${NC}: sprawdzenie są lewe wpisy w bazie"
        $wp_path db search '(<script|eval\(|atob|fromCharCode)' --regex  --table_column_once --all-tables-with-prefix
        echo "Sprawdzono zawartość brzydkich doklejek w kodzie" >> $log_file;
    
#echo -e "${RED} KROK $((++KROK))${NC}: sprawdzenie podatności w aktualnie zainstalowanych wtyczkach/szablonach";
#    $wp_path package install 10up/wpcli-vulnerability-scanner:dev-trunk
#    $wp_path vuln status
#    $wp_path plugin uninstall --deactivate wpcli-vulnerability-scanner
    
echo -e "${RED} KROK $((++KROK))${NC}: czyszczenie (usunięcie wp, cleanera)";
    rm -rf $CURR_PATH/wp
    rm -rf $CURR_PATH/cleaner.sh    
    echo "Usunięto pozostałości po automatycznym usuwaniu wirusów" >> $log_file;
