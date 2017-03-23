var/list/shop = list("item_id" = list())

world
	New()
		shop.Add("item_id/1")
		shop["item_id"]["1"] = list("name","price","item","gold")
		shop["item_id"]["1"]["name"] = "100 Gold two small kitchen knives."
		shop["item_id"]["1"]["price"] = "100"
		shop["item_id"]["1"]["item"] = list("/obj/item_knife","/obj/item_knife22")
		shop["item_id"]["1"]["gold"] = 100

		shop.Add("item_id/2")
		shop["item_id"]["2"] = list("name","price","item","gold")
		shop["item_id"]["2"]["name"] = "1000 Gold + Epic Sword"
		shop["item_id"]["2"]["price"] = "1002"
		shop["item_id"]["2"]["item"] = list("/obj/item_sword")
		shop["item_id"]["2"]["gold"] = 1000

obj
	item_sword
	item_knife
	item_knife22

mob/var/gold = 0

mob
	Stat()
		statpanel("stuffs")
		stat("Gold",usr.gold)
		stat(usr.contents)