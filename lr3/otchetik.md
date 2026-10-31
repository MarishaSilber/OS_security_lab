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
