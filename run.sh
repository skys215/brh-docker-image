sed -i "s~APP_NAME=Laravel~APP_NAME=$APP_NAME~" .env

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
cp $PWD/env.txt /app/docs/

