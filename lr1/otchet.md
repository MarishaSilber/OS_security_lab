# 2.1.2
whoami
pwd
# 2.1.3
cd /
cd ..
# 2.1.4
ls
# 2.1.5
ls /etc
# 2.1.6
cd ~
# 2.1.7
ls
# 2.1.8
ls -la



# 2.2.1
mkdir ~/fruits
# 2.2.2
cd /
mkdir ~/animals
# 2.2.3
touch /tmp/temp
# 2.2.4
echo "Hello" > /tmp/temp
echo "world" >> /tmp/temp
nano /tmp/temp
# 2.2.5
cd ~/fruits
touch apple && touch banana && touch pineaple && touch lion
# 2.2.6
touch ~/animals/cat.txt ~/animals/dog.txt ~/animals/elephant.txt
# 2.2.7
ls a*
# 2.2.8
ls *e
# 2.2.9
ls * a * n *
# 2.2.10
cp /etc/passwd ~
wc -l ~/passwd
ln -s ~/passwd ~/passwd_link
ls -i ~/passwd_link
# 2.2.11
cat /etc/issue
# 2.2.12
cp /etc/issue ~/fruits/apple
cat ~/fruits/apple
# 2.2.13
mv ~/fruits/lion ~/animals/
# 2.2.14
mv ~/fruits/pineaple ~/fruits/pineapple
# 2.2.15
exit
ln ~/.bash_history ~/bash_history_hardlink
ls -l ~/bash_history_hardlink
# 2.2.16
rm -r ~/fruits
# 2.2.17
cat /var/log/syslog



# 2.3.1
cut -d: -f1 /etc/passwd | sort
# 2.3.2
grep '/bin/bash$' /etc/passwd | wc -l
# 2.3.3
grep '/bin/bash$' /etc/passwd | cut -d: -f1 | sort -r
# 2.3.4
cat  /etc/passwd | cut -d: -f1,7 | column -t -s



# 2.4.1
cat /etc/shadow
# 2.4.2
groups
# 2.4.3
sudo cat /etc/shadow
# 2.4.4
getent group sudo
# 2.4.5
sudo apt update
sudo apt install -y build-essential
gcc --version
make --version



# 2.5.1
man find
# 2.5.2
find / -name '*pass*'
# 2.5.3
find / -iname '*pass*' 
# 2.5.4
find / -maxdepth 1 -name '*pass*'
# 2.5.5
find /home -name '*.bin'
# 2.5.6
find / -type f -name '*.bak' -delete
# 2.5.7
find / -type f \( -name '*.txt' -o -name '*.sh' \)
# 2.5.8
find . -type f -printf '%f %u %g %n %s\n'
# 2.5.9
find . -mindepth 1 -type d -empty
# 2.5.10
find . -mindepth 1 -type d -empty -delete
# 2.5.11
find / -type f -empty -delete
# 2.5.12
find . -type f -links +1
# 2.5.13
find /etc ! -user root
# 2.5.14
find / -type f ! -name '*.sh'
# 2.5.15
find / -type f -links +2
# 2.5.16
find /usr/bin -type f -atime +90
# 2.5.17
find /usr/bin /usr/share -type f -mtime -10
# 2.5.18
find /tmp -type f -mtime +14 -delete
