# Домашнее задание к занятию "3.5. Файловые системы"

1. Узнайте о [sparse](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D1%84%D0%B0%D0%B9%D0%BB) (разряженных) файлах.

       Разрежённый файл - файл, в котором последовательности нулевых байтов заменены на информацию об этих последовательностях (список дыр).
       Дыра (англ. hole) — последовательность нулевых байт внутри файла, не записанная на диск. Информация о дырах (смещение от начала файла в байтах и количество байт) хранится в метаданных ФС.

1. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?

        Нет, не могут, это всего лишь ссылки, все аттрибуты будут одинаковы, кроме названия.


1. Сделайте `vagrant destroy` на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:

    ```bash
    Vagrant.configure("2") do |config|
      config.vm.box = "bento/ubuntu-20.04"
      config.vm.provider :virtualbox do |vb|
        lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
        lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
        vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
        vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
      end
    end
    ```

    Данная конфигурация создаст новую виртуальную машину с двумя дополнительными неразмеченными дисками по 2.5 Гб.


        vagrant@vagrant:~$ lsblk
        NAME                 MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
        sda                    8:0    0   64G  0 disk
        ├─sda1                 8:1    0  512M  0 part /boot/efi
        ├─sda2                 8:2    0    1K  0 part
        └─sda5                 8:5    0 63.5G  0 part
          ├─vgvagrant-root   253:0    0 62.6G  0 lvm  /
          └─vgvagrant-swap_1 253:1    0  980M  0 lvm  [SWAP]
        sdb                    8:16   0  2.5G  0 disk
        sdc                    8:32   0  2.5G  0 disk

1. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.

        vagrant@vagrant:~$ lsblk
        NAME                 MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
        sda                    8:0    0   64G  0 disk
        ├─sda1                 8:1    0  512M  0 part /boot/efi
        ├─sda2                 8:2    0    1K  0 part
        └─sda5                 8:5    0 63.5G  0 part
          ├─vgvagrant-root   253:0    0 62.6G  0 lvm  /
          └─vgvagrant-swap_1 253:1    0  980M  0 lvm  [SWAP]
        sdb                    8:16   0  2.5G  0 disk
        ├─sdb1                 8:17   0  1.9G  0 part
        └─sdb2                 8:18   0  652M  0 part
        sdc                    8:32   0  2.5G  0 disk

1. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.


        vagrant@vagrant:~$ sudo sfdisk -d /dev/sdb > part_table
        vagrant@vagrant:~$ sudo sfdisk /dev/sdc < part_table

1. Соберите `mdadm` RAID1 на паре разделов 2 Гб.

        sudo mdadm --create --verbose /dev/md1 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1

1. Соберите `mdadm` RAID0 на второй паре маленьких разделов.

        sudo mdadm --create --verbose /dev/md0 --level=0 --raid-devices=2 /dev/sdb2 /dev/sdc2

1. Создайте 2 независимых PV на получившихся md-устройствах.


        root@vagrant:/home/vagrant# pvcreate /dev/md0
          Physical volume "/dev/md0" successfully created.
        root@vagrant:/home/vagrant# pvcreate /dev/md1
          Physical volume "/dev/md1" successfully created.
        root@vagrant:/home/vagrant# pvs
          PV         VG        Fmt  Attr PSize   PFree
          /dev/md0             lvm2 ---   <1.27g <1.27g
          /dev/md1             lvm2 ---    1.86g  1.86g
          /dev/sda5  vgvagrant lvm2 a--  <63.50g     0


1. Создайте общую volume-group на этих двух PV.

        root@vagrant:/home/vagrant# vgcreate VGroup1 /dev/md0 /dev/md1
          Volume group "VGroup1" successfully created
        root@vagrant:/home/vagrant# vgs
          VG        #PV #LV #SN Attr   VSize   VFree
          VGroup1     2   0   0 wz--n-   3.12g 3.12g
          vgvagrant   1   2   0 wz--n- <63.50g    0

1. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.

          root@vagrant:/home/vagrant# lvcreate -L100 VGroup1 /dev/md0
          Logical volume "lvol0" created.
          root@vagrant:/home/vagrant# lsblk
          NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
          sda                    8:0    0   64G  0 disk
          ├─sda1                 8:1    0  512M  0 part  /boot/efi
          ├─sda2                 8:2    0    1K  0 part
          └─sda5                 8:5    0 63.5G  0 part
            ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
            └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
          sdb                    8:16   0  2.5G  0 disk
          ├─sdb1                 8:17   0  1.9G  0 part
          │ └─md1                9:1    0  1.9G  0 raid1
          └─sdb2                 8:18   0  652M  0 part
            └─md0                9:0    0  1.3G  0 raid0
              └─VGroup1-lvol0  253:2    0  100M  0 lvm
          sdc                    8:32   0  2.5G  0 disk
          ├─sdc1                 8:33   0  1.9G  0 part
          │ └─md1                9:1    0  1.9G  0 raid1
          └─sdc2                 8:34   0  652M  0 part
            └─md0                9:0    0  1.3G  0 raid0
              └─VGroup1-lvol0  253:2    0  100M  0 lvm


1. Создайте `mkfs.ext4` ФС на получившемся LV.


        root@vagrant:/home/vagrant# mkfs.ext4 /dev/VGroup1/lvol0
        mke2fs 1.45.5 (07-Jan-2020)
        Creating filesystem with 25600 4k blocks and 25600 inodes

        Allocating group tables: done
        Writing inode tables: done
        Creating journal (1024 blocks): done
        Writing superblocks and filesystem accounting information: done



1. Смонтируйте этот раздел в любую директорию, например, `/tmp/new`.

        root@vagrant:/home/vagrant# mkdir /tmp/lvol0
        root@vagrant:/home/vagrant# mount /dev/mapper/VGroup1-lvol0 /tmp/lvol0

        root@vagrant:/home/vagrant# df -h | grep lvol0
        /dev/mapper/VGroup1-lvol0    93M   72K   86M   1% /tmp/lvol0


1. Поместите туда тестовый файл, например `wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.

        root@vagrant:/tmp/lvol0# ll
        total 20604
        drwxr-xr-x  3 root root     4096 Sep 23 15:06 ./
        drwxrwxrwt 10 root root     4096 Sep 23 15:04 ../
        drwx------  2 root root    16384 Sep 23 14:58 lost+found/
        -rw-r--r--  1 root root 21073712 Sep 23 13:16 test.gz


1. Прикрепите вывод `lsblk`.

        root@vagrant:/tmp/lvol0# lsblk
        NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
        sda                    8:0    0   64G  0 disk
        ├─sda1                 8:1    0  512M  0 part  /boot/efi
        ├─sda2                 8:2    0    1K  0 part
        └─sda5                 8:5    0 63.5G  0 part
          ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
          └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
        sdb                    8:16   0  2.5G  0 disk
        ├─sdb1                 8:17   0  1.9G  0 part
        │ └─md1                9:1    0  1.9G  0 raid1
        └─sdb2                 8:18   0  652M  0 part
          └─md0                9:0    0  1.3G  0 raid0
            └─VGroup1-lvol0  253:2    0  100M  0 lvm   /tmp/lvol0
        sdc                    8:32   0  2.5G  0 disk
        ├─sdc1                 8:33   0  1.9G  0 part
        │ └─md1                9:1    0  1.9G  0 raid1
        └─sdc2                 8:34   0  652M  0 part
          └─md0                9:0    0  1.3G  0 raid0
            └─VGroup1-lvol0  253:2    0  100M  0 lvm   /tmp/lvol0

1. Протестируйте целостность файла:

    ```bash
    root@vagrant:~# gzip -t /tmp/new/test.gz
    root@vagrant:~# echo $?
    0
    ```

        root@vagrant:/tmp/lvol0# gzip -t test.gz
        root@vagrant:/tmp/lvol0# echo $?
        0


1. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.

        root@vagrant:/# lsblk
        NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
        sda                    8:0    0   64G  0 disk
        ├─sda1                 8:1    0  512M  0 part  /boot/efi
        ├─sda2                 8:2    0    1K  0 part
        └─sda5                 8:5    0 63.5G  0 part
          ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
          └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
        sdb                    8:16   0  2.5G  0 disk
        ├─sdb1                 8:17   0  1.9G  0 part
        │ └─md1                9:1    0  1.9G  0 raid1
        │   └─VGroup1-lvol0  253:2    0  100M  0 lvm   /tmp/lvol0
        └─sdb2                 8:18   0  652M  0 part
          └─md0                9:0    0  1.3G  0 raid0
        sdc                    8:32   0  2.5G  0 disk
        ├─sdc1                 8:33   0  1.9G  0 part
        │ └─md1                9:1    0  1.9G  0 raid1
        │   └─VGroup1-lvol0  253:2    0  100M  0 lvm   /tmp/lvol0
        └─sdc2                 8:34   0  652M  0 part
          └─md0                9:0    0  1.3G  0 raid0

1. Сделайте `--fail` на устройство в вашем RAID1 md.

        root@vagrant:/# mdadm --fail /dev/md1 /dev/sdb1
        mdadm: set /dev/sdb1 faulty in /dev/md1

1. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.

        [ 2908.998751] md/raid1:md1: Disk failure on sdb1, disabling device.
               md/raid1:md1: Operation continuing on 1 devices.

1. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:

    ```bash
    root@vagrant:~# gzip -t /tmp/new/test.gz
    root@vagrant:~# echo $?
    0
    ```

        root@vagrant:/# cd /tmp/lvol0/
        root@vagrant:/tmp/lvol0# gzip -t test.gz
        root@vagrant:/tmp/lvol0# echo $?
        0

1. Погасите тестовый хост, `vagrant destroy`.
