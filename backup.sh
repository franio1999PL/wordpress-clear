#!/bin/bash

# Ustawienie zmiennej z datą i godziną do nazwy pliku
backup_time=$(date +"%Y-%m-%d-%H%M%S")

# Utworzenie katalogu na kopie zapasowe, jeśli nie istnieje
mkdir -p backup-data

# Kopiowanie plików WordPressa do katalogu tymczasowego
echo "Kopiowanie plików WordPress..."
cp -a . "backup-data/wp-backup-$backup_time"

# Wyciągnięcie danych konfiguracyjnych do bazy danych z pliku wp-config.php
db_name=$(cat wp-config.php | grep DB_NAME | cut -d \' -f 4)
db_user=$(cat wp-config.php | grep DB_USER | cut -d \' -f 4)
db_password=$(cat wp-config.php | grep DB_PASSWORD | cut -d \' -f 4)
db_host=$(cat wp-config.php | grep DB_HOST | cut -d \' -f 4)

# Zrzut bazy danych
echo "Tworzenie zrzutu bazy danych..."
mysqldump --user="$db_user" --password="$db_password" --host="$db_host" "$db_name" > "backup-data/wp-db-$backup_time.sql"

# Pakowanie plików i bazy danych do jednego pliku zip
echo "Pakowanie plików i bazy danych..."
zip -r "backup-data/$backup_time.zip" "backup-data/wp-backup-$backup_time" "backup-data/wp-db-$backup_time.sql"

# Usunięcie katalogu tymczasowego i pliku SQL
rm -rf "backup-data/wp-backup-$backup_time"
rm "backup-data/wp-db-$backup_time.sql"

# Aktualizacja WordPressa i wtyczek
echo "Aktualizowanie WordPressa i wtyczek..."
wp core update
wp plugin update --all

echo "Proces kopii zapasowej i aktualizacji został zakończony."
