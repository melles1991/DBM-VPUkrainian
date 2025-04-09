#!/bin/bash

# Отримуємо значення FINAL_VERSION з GitHub Actions середовища
version="$FINAL_VERSION"  # Використовуємо передану змінну FINAL_VERSION

# Для отримання попереднього тегу використовуємо git describe
tag=$(git describe --tags --always --abbrev=0)

# Якщо на теге, шукаємо попередній тег
if [ "$version" = "$tag" ]; then
  current="$tag"
  previous=$(git describe --tags --abbrev=0 HEAD~1)  # Шукаємо попередній тег
else
  current=$(git log -1 --format="%H")
  previous="$tag"
fi

# Дата останнього коміту
date=$(git log -1 --date=short --format="%ad")

# URL репозиторію
url=$(git remote get-url origin | sed -e 's/^git@\(.*\):/https:\/\/\1\//' -e 's/\.git$//')

# Створення CHANGELOG.md
echo -ne "# [v${version}](${url}/tree/${current}) ($date)\n\n[Full Changelog](${url}/compare/v${version}...${current})\n\n" > "CHANGELOG.md"

# Якщо на теге, додаємо опис релізу
if [ "$version" = "$tag" ]; then
  # Витягуємо опис релізу
  highlights=$(git cat-file -p "$tag" | sed -e '1,5d' -e '/^-----BEGIN PGP/,/^-----END PGP/d')
  echo -ne "## Highlights\n\n${highlights}\n\n## Commits\n\n" >> "CHANGELOG.md"
fi

# Додаємо коміти між попереднім і поточним тегом
git shortlog --no-merges --reverse "$previous..$current" | sed -e '/^\w/G' -e 's/^      /- /' >> "CHANGELOG.md"
