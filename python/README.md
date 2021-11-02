# Домашнее задание к занятию "4.2. Использование Python для решения типовых DevOps задач"

## Обязательные задания

1. Есть скрипт:
	```python
    #!/usr/bin/env python3
	a = 1
	b = '2'
	c = a + b
	```
	* Какое значение будет присвоено переменной c?
	* Как получить для переменной c значение 12?
	* Как получить для переменной c значение 3?

---
**Ответ:**

*Какое значение будет присвоено переменной c?*
- при попытке присвоения будет ошибка типов в сложении

*Как получить для переменной c значение 12?*
- c = (a + int(b)) * int(b) * int(b)

*Как получить для переменной c значение 3?*
- c = a + int(b)

---

2. Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

	```python
        #!/usr/bin/env python3

        import os

        bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
        result_os = os.popen(' && '.join(bash_command)).read()
        is_change = False
        for result in result_os.split('\n'):
            if result.find('modified') != -1:
                prepare_result = result.replace('\tmodified:   ', '')
                print(prepare_result)
                break

	```
---
**Ответ:**

```python
    #!/usr/bin/env python3

    import os
    import re
    from colorama import Fore, Style

    path = "~/netology/sysadm-homeworks"
    resolved_path = os.path.expanduser(os.path.expandvars(path))

    bash_command = [f"cd {resolved_path}", "git status -s"]
    result_os = os.popen(' && '.join(bash_command)).read()

    for result in result_os.split('\n'):
    if re.search("^ M ", result) != None:
        print(Fore.GREEN + result)
    elif re.search("^ D *", result) != None:
        print(Fore.RED + result)
    elif re.search("^\?\? *", result) != None:
        print(Fore.CYAN + result)

    print(Style.RESET_ALL)
```
---


3. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

---
**Ответ:**
```python
#!/usr/bin/env python3

import os
import re
import sys
from colorama import Fore, Style
import subprocess

if len(sys.argv) > 1:
    path = sys.argv[1]
else:
    path = "~/netology/sysadm-homeworks"

resolved_path = os.path.expanduser(os.path.expandvars(path))

isExist = os.path.isdir(resolved_path)
if not isExist:
    print(f"Such path is not exists or not a directory: {resolved_path}")
    exit()

process = subprocess.Popen(
    ["git", "status", "-s"],
    cwd=resolved_path,
    text=True,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE
)
stdout, stderr = process.communicate()
if stderr:
    print("Not a git repository")
    print(f"Original error: {stderr}")
    exit()

for result in stdout.split("\n"):
    if re.search("^ M ", result) != None:
        print(Fore.GREEN + result)
    elif re.search("^ D *", result) != None:
        print(Fore.RED + result)
    elif re.search("^\?\? *", result) != None:
        print(Fore.CYAN + result)

print(Style.RESET_ALL)
```
---

4. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: drive.google.com, mail.google.com, google.com.

---
**Ответ:**

```python
import socket
import time

services = {"drive.google.com": {"ip": "192.168.0.1"}, "mail.google.com": {
    "ip": "172.16.0.1"}, "google.com": {"ip": "10.0.0.1"}}

while True:
    for domain_name in services.keys():
        current_ip = services[domain_name]["ip"]
        checked_ip = socket.gethostbyname(domain_name)
        if checked_ip == current_ip:
            print(f"""{domain_name} - {current_ip}""")
        else:
            print(f"""[ERROR] {domain_name} IP mismatch: {current_ip} {checked_ip}""")
            services[domain_name]["ip"] = checked_ip
    print("-----------------------------------")
    time.sleep(5)
```

---


---

### Как сдавать задания?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---