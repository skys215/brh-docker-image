# 传进container里
export APP_NAME="工资绩效核算系统"
export PROJECT_NAME="salary"
export THEME_NAME="tabler"

# prepare
rm -rf $PROJECT_NAME
composer create-project laravel/laravel $PROJECT_NAME "dev-$THEME_NAME" --repository='{"type":"vcs","url":"git@github.com:skys215/brh9.git"}'
cd $PROJECT_NAME
sed -i "s~APP_NAME=Laravel~APP_NAME=$APP_NAME~" .env
sed -i 's~DB_CONNECTION=mysql~DB_CONNECTION=sqlite~' .env
sed -i "s~DB_DATABASE=laravel~DB_DATABASE=$PWD/db.sqlite~" .env
chmod -R 777 bootstrap/ storage/
php artisan dusk:install
ln -sf /usr/bin/chromedriver ./vendor/laravel/dusk/bin/chromedriver-linux
chmod -R 0755 vendor/laravel/dusk/bin/
rm -rf tests/Browser/ExampleTest.php

# db
touch db.sqlite
php artisan migrate
php artisan tinker --execute="\App\Models\User::factory()->create(['name' => 'Super Admin', 'email' => 'admin@admin.com', 'password' => bcrypt('password')]);"

# creation
# 传进resources/model_schemas里
# 循环执行
for file in /app/json/*; do
  filename=$(basename -- "$file");
  ext="${filename##*.}";
  name="${filename%.*}";
  vars=($(echo $name |sed -E 's/-/ /g'));
  cp $file ./resources/model_schemas/"${vars[0]}".json ;
  php artisan infyom:scaffold ${vars[0]} --fieldsFile="${vars[0]}.json"  --forceMigrate --locales="zh_CN:${vars[1]}";
  php artisan tinker --execute="\\App\\Models\\${vars[0]}::factory()->count(25)->create();";
done

# run
nohup php artisan serve --port 80 &
php artisan dusk
php artisan ruanzhu:doc

cp $PWD/*.docx /app/docs/

