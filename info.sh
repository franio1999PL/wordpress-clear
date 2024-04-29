#!/bin/bash

# Sprawdzanie, czy WP-CLI jest zainstalowane
if ! command -v wp &> /dev/null
then
    echo "WP-CLI nie jest zainstalowane. Zainstaluj WP-CLI, aby kontynuować."
    exit 1
fi

# Przechodzenie do katalogu WordPress
# Zmień '/ścieżka/do/wordpress' na rzeczywistą ścieżkę do Twojej instalacji WordPress
cd /ścieżka/do/wordpress

# Wypisywanie informacji o WordPress
echo "Informacje o WordPress:"
wp core version --extra

# Wypisywanie informacji o PHP
echo "Aktualna wersja PHP:"
php -v
