#!/bin/bash

# Sprawdzanie, czy WP-CLI jest zainstalowane
if ! command -v wp &> /dev/null
then
    echo "WP-CLI nie jest zainstalowane. Zainstaluj WP-CLI, aby kontynuować."
    exit 1
fi

# Ustawienie aktualnego katalogu jako katalogu WordPress
current_dir=$(pwd)

# Przechodzenie do katalogu WordPress
echo "Przechodzenie do katalogu WordPress: $current_dir"
cd "$current_dir"

# Wypisywanie informacji o WordPress
echo "Informacje o WordPress:"
wp core version --extra

# Wypisywanie informacji o PHP
echo "Aktualna wersja PHP:"
php -v
