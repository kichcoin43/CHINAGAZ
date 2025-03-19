#!/bin/bash
# Скрипт сборки для Render.com

# Install dependencies
npm install
npm install --save-dev @babel/core @babel/preset-env @babel/preset-react @babel/runtime vite
npm install --save-dev @babel/plugin-transform-runtime @babel/plugin-syntax-bigint @babel/plugin-syntax-class-properties

# Create temporary babel config if it doesn't exist
echo '{
  "presets": ["@babel/preset-env", "@babel/preset-react"],
  "plugins": [
    "@babel/plugin-transform-runtime",
    "@babel/plugin-syntax-bigint",
    "@babel/plugin-syntax-class-properties"
  ]
}' > .babelrc

npm run build

echo "============================================"
echo "Запуск скрипта сборки для Render.com..."
echo "============================================"

# Создаем директорию для хранения данных, если она не существует
echo "Проверка и создание директорий для хранения данных..."
mkdir -p data
mkdir -p data/backup

# Копируем базу данных из рабочей директории в постоянное хранилище, если она существует
if [ -f "sqlite.db" ]; then
  echo "Сохранение существующей базы данных в постоянное хранилище..."
  cp sqlite.db data/sqlite.db
  echo "База данных скопирована в директорию data"
fi

# Создаем резервную копию базы данных с временной меткой, если база существует
if [ -f "data/sqlite.db" ]; then
  TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
  echo "Создание резервной копии базы данных с временной меткой $TIMESTAMP..."
  cp data/sqlite.db "data/backup/backup_$TIMESTAMP.db"
  echo "Резервная копия создана в data/backup/backup_$TIMESTAMP.db"

  # Удаляем старые резервные копии (оставляем только последние 5)
  echo "Удаление старых резервных копий..."
  ls -t data/backup/backup_*.db | tail -n +6 | xargs -r rm
  echo "Старые резервные копии удалены"
fi

echo "============================================"
echo "Сборка успешно завершена!"
echo "============================================"
