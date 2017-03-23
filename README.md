# BYOND-PayPal-Shop
A terrible implementation for shops using BYOND and PayPal.
###########################
Simple PayPal Shop Example.

This will get you started on setting up a shop using PayPal as a payment gateway.

You will in the end need your own webserver with the following set up.

PHP
MySQL with remote access, Easily done with SQLite with a few changes.
A webserver to serve the files, Nginx, Apache2 etc


When using this demo you can easily purchase one of the two items in the shop, the username and password for doing so are under the PAYPAL SANDBOX.dm file (Sandbox Personal account)


Currently the "delete" feature is disable as permissions on the MySQL user are locked down to prevent fools from DROPing the database as a whole, which would render the demo useless..


Installation by cloning the repo, you'll want to do one thing ..

git submodule update --init --recursive