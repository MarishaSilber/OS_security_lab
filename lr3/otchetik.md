# 2.1.1
mkdir ~/test
cd ~/test
touch file
ls -l file #-rw-rw-r-- or 664

# 2.1.2
chmod 000 file
echo "stroka" > file #Permission denied
cat file #Permission denied

# 2.1.3
chmod u=w,go= file #-w------- or 200
echo "stroka" > file #успех
cat file #Permission denied

# 2.1.4
chmod g+r file #--w-r----- or 240
ls -l file
cat file #Permission denied

# 2.1.5
chmod u+r file #-rw-r----- or 640
cat file #успех

# 2.1.6
mkdir dir
echo "lol" > dir/new_file
ls -l dir

# 2.1.7
chmod a-x dir #было 755 rwxr-xr-x, стало 644 rw-r--r--
cat dir/new_file #Permission denied
rm dir/new_file #Permission denied

# 2.1.8
chown root file #Operation not permitted

# 2.1.9
umask 077
touch file2
ls -l file2 #-rw------- or 600 вместо 666 по кд
mkdir dir2
ls -ld dir2 #drwx------ or 700 вместо 777

# 2.1.10
umask 000
touch file3
ls -l file3 #-rw-rw-rw- 666

# 2.1.11
sudo su -
chown root /home/marishasilber/test/file
chmod 400 /home/marishasilber/test/file
exit

# 2.1.12
cat file #Permission denied -r-------- root marishasilber
sudo chmod 440 file
cat file #успех -r--r----- root marishasilber



# 2.2.1
whoami
id
id -u
id -g
groups

# 2.2.2
getent passwd $USER
getent group $(id -gn)

# 2.2.3
sudo groupadd labroup
getent group labroup #labroup:x:1001:

# 2.2.4
sudo useradd -m -s /bin/bash labuser
getent passwd labuser #labuser:x:1001:1002::/home/labuser:/bin/bash
id labuser

# 2.2.5
sudo passwd labuser
su - labuser
whoami
id
pwd #/home/labuser
exit

# 2.2.6
su - labuser
touch ~/myfile
ls -l ~/myfile #-rw-rw-rw- 1 labuser labuser владелец labuser, группа labuser тк все запущенные процессы имеют эффективный uid и gid labuser
exit

# 2.2.7
sudo usermod -aG labroup labuser
id labuser
su - labuser
id
exit
#Если сеанс labuser уже был открыт до изменения, в нём id покажет старый набор групп. Список групп копируется в процесс при входе в систему и наследуется всеми дочерними процессами. Изменение /etc/group на уже запущенные процессы не влияет. Чтобы увидеть группу, нужен новый вход

# 2.2.8
sudo useradd -m -s /bin/bash labuser2
sudo usermod -aG labroup labuser2
getent group labroup #labroup:x:1001:labuser,labuser2
id labuser
id labuser2

# 2.2.9
mkdir /tmp/lab_shared
sudo chown :labroup /tmp/lab_shared
sudo chmod 770 /tmp/lab_shared
ls -ld /tmp/lab_shared #drwxrwx--- marishasilber labroup
su labuser -c 'touch /tmp/lab_shared/from_labuser'
su labuser2 -c 'touch /tmp/lab_shared/from_labuser2'
ls -l /tmp/lab_shared

# 2.2.10
su labuser -c 'echo data > /tmp/lab_shared/lu_file'
ls -l /tmp/lab_shared/lu_file #-rw-rw-r-- labuser labuser
su labuser2 -c 'cat /tmp/lab_shared/lu_file'
su labuser2 -c 'echo more >> /tmp/lab_shared/lu_file'
su labuser2 -c 'rm /tmp/lab_shared/lu_file'
#Чтение и изменение зависят от прав самого файла, файл принадлежит группе labuser, labuser2 в ней не состоит, значит применяются права ост: r-- : читать можно, писать нельзя.
Удаление зависит от прав каталога (w + x для группы labgroup), а не от прав файла. Поэтому labuser2 может удалить чужой файл, даже не имея права его изменить.

# 2.2.11
su labuser -c 'touch /tmp/lab_shared/before1'
su labuser2 -c 'touch /tmp/lab_shared/before2'
ls -l /tmp/lab_shared/before*
#-rw-rw-r-- 1 labuser  labuser
#-rw-rw-r-- 1 labuser2 labuser2 
sudo chmod g+s /tmp/lab_shared
ls -ld /tmp/lab_shared #drwxrws--- 2 marishasilber labroup
su labuser -c 'touch /tmp/lab_shared/after1'
su labuser2 -c 'touch /tmp/lab_shared/after2'
ls -l /tmp/lab_shared/after*
#-rw-rw-r-- 1 labuser labroup
#-rw-rw-r-- 1 labuser2 labroup

# 2.2.12
mkdir /tmp/lab_sticky
sudo chmod 777,+t /tmp/lab_sticky
ls -ld /tmp/lab_sticky #drwxrwxrwt marishasilber marishasilber
su labuser -c 'touch /tmp/lab_sticky/f1' #rm: cannot remove
su labuser2 -c 'touch /tmp/lab_sticky/f2' #свой файл удалил

# 2.2.13
sudo usermod -L labuser
sudo passwd -S labuser #L
su - labuser #su: Authentication failure
sudo usermod -U labuser
sudo passwd -S labuser #P
exit

# 2.2.14
sudo chage -l labuser
sudo chage -d 0 labuser
sudo chage -l labuser
su - labuser

# 2.2.15
cat /etc/shells
sudo usermod -s /bin/sh labuser
getent passwd labuser #labuser:x:1001:1002::/home/labuser:/bin/sh
sudo usermod -s /bin/bash labuser
getent passwd labuser #labuser:x:1001:1002::/home/labuser:/bin/bash

# 2.2.16
su labuser2 -c 'touch /home/labuser2/note.txt'
sudo userdel labuser2
ls -ld /home/labuser2
sudo ls -la /home/labuser2 #права каталога 750, а владельца уже нет
sudo ls -ln /home/labuser2  
#У оставшихся файлов владелец и группа показываются числами имени, соответствующего UID, больше нет. Если позже создать пользователя с тем же UID, он унаследует эти файлы.

# 2.2.17
cat /etc/passwd

# 2.2.18
grep -E '^#?\s*(UID_MIN|UID_MAX|SYS_UID_MIN|SYS_UID_MAX)\s' /etc/login.defs
awk -F: '{print $3, $1}' /etc/passwd | sort -n
awk -F: '$3>=1000 && $3<=60000 {print "обычный:", $1, $3}' /etc/passwd
awk -F: '$3>=100 && $3<=999 {print "системный:", $1, $3}' /etc/passwd

# 2.2.19
sudo useradd -m -s /bin/bash testuser
sudo passwd testuser
sudo useradd -r testsystem
getent passwd testuser testsystem
#testuser:x:1002:1003::/home/testuser:/bin/bash
#testsystem:x:997:973::/home/testsystem:/bin/sh

# 2.2.20
sudo userdel testsystem
sudo useradd -r -m testsystem
getent passwd testsystem

# 2.2.21
grep -E 'nologin|false' /etc/passwd
which nologin false
#/usr/sbin/nologin
#/usr/bin/false
nologin; echo "$?" #This account is currently not available. 1
false ; echo "$?" #1
#Обе программы используются как "оболочка" служебных учётных записей, чтобы нельзя было войти интерактивно.

# 2.2.22
sudo usermod -s /usr/sbin/nologin testuser
su - testuser
sudo su -s /bin/bash testuser -c id
sudo -u testuser id

# 2.2.23
sudo usermod -s /bin/false testuser
su - testuser
echo "код: $?"
sudo su -s /bin/bash testuser -c id
sudo -u testuser id

# 2.2.24
sudo usermod -s /bin/bash testuser
su - testuser
whoami
exit

# 2.2.25
sudo usermod -s /usr/bin/id testuser
getent passwd testuser
sudo su - testuser #запустилась программа id и сеанс завершился
sudo usermod -s /bin/bash testuser
getent passwd testuser

# 2.2.26
sudo groupadd -r testsystemgroup
sudo groupadd testgroup
getent group testsystemgroup testgroup
#testsystemgroup:x:972:
#testgroup:x:1004:

# 2.2.27
grep -E '^#?\s*(GID_MIN|GID_MAX|SYS_GID_MIN|SYS_GID_MAX)\s' /etc/login.defs

# 2.2.28
sudo useradd -r -g testsystemgroup -M -s /usr/sbin/nologin serviceuser
getent passwd serviceuser #serviceuser:x:994:972::/home/serviceuser:/usr/sbin/nologin
id serviceuser
ls -ld /home/serviceuser

# 2.2.29
su - testuser
sudo id #sudo: I'm sorry testuser. I'm afraid I can't do that, не состоит в группе sudo

# 2.2.30
which id
sudo visudo -f /etc/sudoers.d/testuser #testuser ALL=(root) /usr/bin/id, /usr/bin/whoami
su - testuser
sudo id
sudo -l
sudo whoami #провал
exit

# 2.2.31
sudo visudo -f /etc/sudoers.d/testuser #testuser ALL=(root) /usr/bin/id, /usr/bin/whoami
su - testuser
sudo id
sudo whoami
sudo cat /etc/shadow #отказ
sudo -l
exit

# 2.2.32
sudo groupadd testadmins
sudo visudo -f /etc/sudoers.d/testuser #%testadmins ALL=(root) /usr/bin/id
sudo usermod -aG testadmins testuser
su - testuser
id
sudo id
exit

sudo gpasswd -d testuser testadmins
su - testuser
id
sudo id #sudo: I'm sorry testuser. I'm afraid I can't do that
exit

# 2.2.33
man login.defs
sudo useradd -D
man groupadd

# 2.2.34
grep -E '^UID_(MIN|MAX)' /etc/login.defs
sudo sed -i -E 's/^#?UID_MIN[[:space:]]+.*/UID_MIN 5000/' /etc/login.defs
grep -E '^UID_MIN[[:space:]]' /etc/login.defs
sudo useradd -m configuser1 #id configuser1 #uid=5000(configuser1) gid=5000(configuser1) groups=5000(configuser1)
getent passwd configuser1
sudo cp -a /etc/login.defs.orig /etc/login.defs
grep '^UID_MIN' /etc/login.defs

# 2.2.35
sudo sed -i -E 's/^#?SYS_UID_MIN[[:space:]]+.*/SYS_UID_MIN 700/' /etc/login.defs
grep -E '^SYS_UID_MIN[[:space:]]' /etc/login.defs
sudo sed -i -E 's/^#?SYS_UID_MAX[[:space:]]+.*/SYS_UID_MAX 710/' /etc/login.defs
sudo sed -i -E 's/^#?SYS_UID_MAX[[:space:]]+.*/SYS_UID_MIN 700/' /etc/login.defs
grep -E '^SYS_UID_MAX[[:space:]]' /etc/login.defs
sudo useradd -r sysconfig1
sudo useradd -r sysconfig2
sudo useradd -r sysconfig3
id sysconfig1 sysconfig2 sysconfig3
sudo userdel sysconfig1; sudo userdel sysconfig2; sudo userdel sysconfig3
sudo cp -a /etc/login.defs.orig /etc/login.defs
#uid=710(sysconfig1) gid=710(sysconfig1) groups=710(sysconfig1)
#uid=709(sysconfig2) gid=709(sysconfig2) groups=709(sysconfig2)
#uid=708(sysconfig3) gid=708(sysconfig3) groups=708(sysconfig3)

# 2.2.36
sudo sed -i -E 's/^#?GID_MIN[[:space:]]+.*/GID_MIN 6000/' /etc/login.defs
grep -E '^GID_MIN[[:space:]]' /etc/login.defs
sudo groupadd configgroup1
getent group configgroup1 # GID 6000
sudo groupdel configgroup1
sudo cp -a /etc/login.defs.orig /etc/login.defs

# 2.2.37
sudo sed -i -E 's/^#?SYS_GID_MIN[[:space:]]+.*/SYS_GID_MIN 700/' /etc/login.defs
grep -E '^SYS_GID_MIN[[:space:]]' /etc/login.defs
sudo sed -i -E 's/^#?SYS_GID_MAX[[:space:]]+.*/SYS_GID_MAX 710/' /etc/login.defs
grep -E '^SYS_GID_MAX[[:space:]]' /etc/login.defs
sudo groupadd -r sysgroup1
sudo groupadd -r sysgroup2
sudo groupadd -r sysgroup3
getent group sysgroup1 sysgroup2 sysgroup3     # 710, 709, 708
sudo groupdel sysgroup1; sudo groupdel sysgroup2; sudo groupdel sysgroup3
sudo cp -a /etc/login.defs.orig /etc/login.defs

# 2.2.38
grep -E 'CREATE_HOME' /etc/login.defs
grep -qE '^CREATE_HOME[[:space:]]' /etc/login.defs || echo 'CREATE_HOME yes' | sudo tee -a /etc
/login.defs
grep -E '^CREATE_HOME[[:space:]]' /etc/login.defs
sudo useradd homeuser1
ls -ld /home/homeuser1
sudo sed -i -E 's/^#?CREATE_HOME[[:space:]]+.*/CREATE_HOME no/' /etc/login.defs
grep -E '^CREATE_HOME[[:space:]]' /etc/login.defs
sudo useradd homeuser2
ls -ld /home/homeuser2
sudo userdel -r homeuser1
sudo userdel homeuser2
sudo cp -a /etc/login.defs.orig /etc/login.defs

# 2.2.39
grep -qE '^#?CREATE_HOME[[:space:]]' /etc/login.defs 
echo 'CREATE_HOME yes' | sudo tee -a /etc/login.defs
grep -E '^CREATE_HOME[[:space:]]' /etc/login.defs
sudo useradd -r syshome1 #ls: cannot access '/home/syshome1': No such file or directory
sudo useradd -r -m syshome2
ls -ld /home/syshome2
sudo userdel syshome1
sudo userdel -r syshome2
sudo cp -a /etc/login.defs.orig /etc/login.defs
#CREATE_HOME не распространяется на системных пользователей -r: в документации useradd сказано, что для них каталог не создаётся независимо от этой настройки, нужно явное -m

# 2.2.40
grep -E '^(UMASK|HOME_MODE)' /etc/login.defs
umask
sudo useradd -m umaskuser1
stat -c '%a %n' /home/umaskuser1 # это 750
sudo sed -i -E 's/^#?HOME_MODE[[:space:]]+.*/HOME_MODE 0700/' /etc/login.defs 
grep -E '^HOME_MODE[[:space:]]' /etc/login.defs
sudo useradd -m umaskuser2
stat -c '%a %n' /home/umaskuser2 # это 700
sudo userdel -r umaskuser1
sudo userdel -r umaskuser2
sudo cp -a /etc/login.defs.orig /etc/login.defs

# 2.2.41
grep -E '^USERGROUPS_ENAB' /etc/login.defs
sudo useradd -m ugenab1
id ugenab1
sudo sed -i -E 's/^#?USERGROUPS_ENAB[[:space:]]+.*/USERGROUPS_ENAB no/' /etc/login.defs
grep -E '^USERGROUPS_ENAB[[:space:]]' /etc/login.defs
sudo useradd -m ugenab2
id ugenab2 #uid=1005(ugenab2) gid=100(users) groups=100(users)
getent group ugenab2 #пусто 
sudo userdel -r ugenab1
sudo userdel -r ugenab2
sudo cp -a /etc/login.defs.orig /etc/login.defs

#2.2.42
sudo useradd -D | grep SHELL #SHELL=/bin/sh
sudo useradd -D -s /bin/bash
sudo useradd -D | grep SHELL #SHELL=/bin/bash
sudo useradd -m defaultuser1
getent passwd defaultuser1 #defaultuser1:x:1004:1008::/home/defaultuser1:/bin/bash

# 2.2.43
sudo mkdir -p /srv/home
sudo useradd -D -b /srv/home 
sudo useradd -D | grep HOME
sudo useradd -m defaultuser2
getent passwd defaultuser2 #defaultuser2:x:1005:1009::/srv/home/defaultuser2:/bin/bash


