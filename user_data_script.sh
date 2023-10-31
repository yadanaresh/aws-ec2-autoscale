#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo service httpd start
sudo chkconfig on
sudo chmod -r 755 /var/www/

cat <<HTML > /var/www/html/index.html
<!DOCTYPE html>
<html>
  <head>
    <title>Server Details</title>
  </head>
  <body>
    <h1>Server Details</h1>
    <p><strong>Hostname:</strong> hostname</p>
    <p><strong>IP Address:</strong> $(hostname -I | awk '{print $1}')</p>
  </body>
</html>
HTML
