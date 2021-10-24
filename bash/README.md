# Домашнее задание к занятию "4.1. Командная оболочка Bash: Практические навыки"

## Обязательные задания

1. Есть скрипт:
	```bash
	a=1
	b=2
	c=a+b
	d=$a+$b
	e=$(($a+$b))
	```
	* Какие значения переменным c,d,e будут присвоены?
	* Почему?
---

            a=1 неявное объявление целочисленного
	        b=2 неявное объявление целочисленного

            с=a+b неявное определение строки
            echo $c => a+b

            d=$a+$b - подстановка значений в строку, но исполнение арифметических операций не происходит
            echo $d => 1+2

            e=$(($a+$b)) - стандартная арифметическая операция над целочисленными
            echo $e => 3
---

2. На нашем локальном сервере упал сервис и мы написали скрипт, который постоянно проверяет его доступность, записывая дату проверок до тех пор, пока сервис не станет доступным. В скрипте допущена ошибка, из-за которой выполнение не может завершиться, при этом место на Жёстком Диске постоянно уменьшается. Что необходимо сделать, чтобы его исправить:
	```bash
	while ((1==1)
	do
	curl https://localhost:4757
	if (($? != 0))
	then
	date >> curl.log
	fi
	done
	```
---
 1. Пропущена закрывающая скобка в 1 строке, синтаксическая ошибка
 2. Не совсем понял задачу

 Если нам надо, чтобы и дальше проверял и записывал при падении сервера, то оставляем так

```bash
while ((1==1))
do
    curl https://localhost:4757

    if (($? != 0))
    then
        date >> curl.log
    fi
done
```

Если надо прекратить проверку, после восстановления

```bash
while ((1==1))
do
    curl https://localhost:4757

    if (($? != 0))
    then
        date >> curl.log
    else
        break
    fi
done
```


---

3. Необходимо написать скрипт, который проверяет доступность трёх IP: 192.168.0.1, 173.194.222.113, 87.250.250.242 по 80 порту и записывает результат в файл log. Проверять доступность необходимо пять раз для каждого узла.

---
```bash
ips=("192.168.0.1" "173.194.222.113" "87.250.250.242")

for ip in ${ips[@]}
do

	a=5
	while (($a>0))
	do
		nc -z $ip 80
		echo $? >> /tmp/ping_result.log
		let "a -= 1"
	done

done
```


---

4. Необходимо дописать скрипт из предыдущего задания так, чтобы он выполнялся до тех пор, пока один из узлов не окажется недоступным. Если любой из узлов недоступен - IP этого узла пишется в файл error, скрипт прерывается

---
```bash
ips=("192.168.0.1" "173.194.222.113" "87.250.250.242")

for ip in ${ips[@]}
do
        a=5
        error=0
        while (($a>0))
        do
                nc -zw1 $ip 80
                if (($? != 0))
                then
                        echo $ip >> /tmp/ip_error.log
                        error=1
                        break
                else
                        let "a -= 1"
                fi
        done

        if (($error == 1))
        then
                break
        fi
done
```

---