### Devops netology course

**Terraform**

Файлы, которые будут проигнорированы в дир-ии terraform:
- Во всех вложенных директориях, где есть дир-ия .terraform, внутри этой папки все файлы, пример

      terraform/.terraform/example.txt

      terraform/some/.terraform/example.txt

      terraform/some/next/.terraform/example.txt

- Все файлы с расширением tfstate, а также вида `exam.tfstate.ple`
- Исключаем `crash.log`
- Все файлы с расширением `.tfvars`
- Файлы используемые для перезаписи, вида:

      override.tf

      override.tf.json

      any_name_override.tf

      any_name_override.tf.json

- Можно сделать исключение из правил выше - файл `example_override.tf`. Его оставляем, если нужен пример настройки.

- Все файлы с расширением `.terraformrc`, а также `terraform.rc`

To be continue...
