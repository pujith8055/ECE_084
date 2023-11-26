# ECE_084
Linux bash scripting

# SETUP
- Create three files in the same directory (Tasks, Reminders, Done).

- add this command to crontabs **"0 9 * * * /location of the auto_file_replace.bash/"**.
  - This will replace the Done and Reminder files every day at 9 am if all the files are placed in the same directory.

# SMTP Send-only Mail setup
- install **"postfix"** and **"mailutils"**.
- go to **"/etc/postfix/"** and edit **"main.cf"**.
- add or change these lines at the bottom.

relayhost = [smtp.gmail.com]:587
smtp_sasl_auth_enable= yes
smtp_sasl_password_maps= hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options= noanonymous
smtp_use_tls= yes
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = loopback-only
inet_protocols = all

- now go to **"google account > security > 2-step verification > App passwords"** create a new app and write down the password.
- now create a new file named **"sasl_passwd"** in **"/etc/postfix/"**.
- now add **"[smtp.gmail.com]:587 sender_mail_address:App_password"** to **"sasl_passwd"** file.
- now give the file permissions:
  - **"sudo chmod 400 /etc/postfix/sasl_passwd"**
- run this command:
  - **"sudo postmap /etc/postfix/sasl_passwd"**
- now reload postfix:
  - **"sudo /etc/init.d/postfix reload"**

- Testing- **" mail -s "Testing" receiver_mail_address <<< "Working" "**
