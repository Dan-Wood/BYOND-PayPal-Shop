/*

sandbox, this allows you to use and test using PayPal's sandbox site,
you'll want to change php/ipn.php ($listener->use_sandbox = true;) to false and sandbox to 0 when going "live" and putting that file in with the contents of PHP-PayPal-IPN, but that's up to you.

db_ are quite self explanatory, details of the MySQL database you're going to use.
DBI does not need to be modified.

paypal_account the paypal account either Merchant Sandbox or real paypal account details.

*/



#define sandbox 1
#define db_username "paypal"
#define db_password "JxyYYe6YbYtqppwB"
#define db_database "paypal_payments"
#define db_server "mysql.byondpanel.com"
#define db_server_port "3306"
#define DBI "dbi:mysql:[db_database]:[db_server]:[db_server_port]"
#define paypal_account "sandbox@byondpanel.com"


proc
	Check_Payment_System()
		var/DBConnection/dbcon = new()
		var/connected = dbcon.Connect(DBI,db_username,db_password)
		if(!connected)
			alert("Connection failed to MySQL Database: [dbcon.ErrorMsg()]")
		else
			var/DBQuery/qr = dbcon.NewQuery("SELECT * FROM `[db_database]`.`payments` WHERE `ckey`='[usr.ckey]' AND `used`='0';")
			qr.Execute()
			if(qr.RowCount())
				while(qr.NextRow())
					var/list/row_data = qr.GetRowData()
					if(shop["item_id"][row_data["item_id"]])

						if(shop["item_id"][row_data["item_id"]]["item"])
							for(var/a in shop["item_id"][row_data["item_id"]]["item"])
								world << text2path(a)
								var/item = text2path("[a]")
								usr.contents += new item

						if(shop["item_id"][row_data["item_id"]]["gold"])
							usr.gold += text2num("[shop["item_id"][row_data["item_id"]]["gold"]]")

					var/DBQuery/update = dbcon.NewQuery("UPDATE  `[db_database]`.`payments` SET  `used` =  '1' WHERE  `payments`.`id` = '[row_data["id"]]';")
					update.Execute()
					update.Close()

			qr.Close()
			dbcon.Disconnect()


	Delete_Payment(var/id)
		var/DBConnection/dbcon = new()
		var/connected = dbcon.Connect(DBI,db_username,db_password)
		if(!connected)
			alert("Connection failed to MySQL Database: [dbcon.ErrorMsg()]")
		else
			var/DBQuery/qr = dbcon.NewQuery("DELETE FROM `[db_database]`.`payments` WHERE `id`='[id]' AND `used`='1';")
			qr.Execute()
			qr.Close()
			dbcon.Disconnect()
			usr.Payment_History_check()

	// You could easily keep this for "live" giving admins a way to search past purchases.
	Payment_History()
		var/DBConnection/dbcon = new()
		var/connected = dbcon.Connect(DBI,db_username,db_password)
		if(!connected)
			alert("Connection failed to MySQL Database: [dbcon.ErrorMsg()]")
		else
			var/DBQuery/qr = dbcon.NewQuery("SELECT * FROM `[db_database]`.`payments`;")
			qr.Execute()
			var/html = {"
			Payment History
			<BR>
			<table border='1' style="width:100%">
			<TR>
				<TD>ckey</TD>
				<TD>item_id</TD>
				<TD>has been used?</TD>
				<TD>Options</TD>
			</TR>

			"}

			if(qr.RowCount())
				while(qr.NextRow())
					var/list/row_data = qr.GetRowData()

					html += {"
					<TR>
						<TD>[row_data["ckey"]]</TD>
						<TD>[row_data["item_id"]]</TD>
						<TD>[row_data["used"]]</TD>

						<TD><a href=\"?src=\ref[src];action=delete&id=[row_data["id"]]\">Delete</a></TD>

					</TR>"}
			//else // you don't really need this, unless you want players to feel bad.
			//	alert("No items!") // you don't really need this, unless you want players to feel bad.
			html += "</table>"
			qr.Close()
			dbcon.Disconnect()
			return html



client
	Topic(href,href_list[],hsrc)
		switch(href_list["action"])
			if("delete")
				Delete_Payment(href_list["id"])


/*

This is just an example, there's nothing to say that you can't do this on a webserver using another language, HTML PHP etc.

Doing this in anything other than BYOND will not carry over the users ckey, obviously.

*/
mob
	verb
		Shop()
			var/html = {"
			<html><head></head><body>
			<h1>SHOP</h1>
			<table border=1>

				<TR>
					<TD>Name</TD>
					<TD>Price</TD>
					<TD>Buy</TD>
				</TR>
			"}
			for(var/i=1, i<shop.len, i++)
				html += {"
					<TR>
						<TD>[shop["item_id"]["[i]"]["name"]]</TD>
						<TD>[shop["item_id"]["[i]"]["price"]]</TD>
						<TD>
							<form action="https://www.[sandbox ? "sandbox." : ""]paypal.com/cgi-bin/webscr" method="post" target="_self">
							<input type="hidden" name="cmd" value="_xclick" />
							<input type="hidden" name="business" value="[paypal_account]"/>
							<input type="hidden" name="item_name" value="[src.ckey]"/>
							<input type="hidden" name="item_number" value="[i]"/>
							<input type="hidden" name="amount" value="[shop["item_id"]["[i]"]["price"]]"/>
							<input type="hidden" name="currency_code" value="USD"/>
							<input type="hidden" name="lc" value="US"/>
							<input type="hidden" name="bn" value="btn_buynow_SM.gif"/>
							<input type="hidden" name="weight_unit" value="kgs"/>
							<input type="image" src="https://www.paypal.com/en_US/i/btn/btn_buynow_SM.gif" name="submit" alt="Make payments with PayPal"/>
							</form>
						</TD>
					</TR>
				"}
			html += "</html></body>"
			usr << browse(html)