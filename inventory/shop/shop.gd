extends Node

func buy_item(item: ItemData) -> bool:
	if not item:
		return false
	if ItemInventory.coins < item.buy_price:
		print("not enough $$$")
		return false
	
	if ItemInventory.add_item(item):
		ItemInventory.remove_coins(item.buy_price)
		return true
	return false

func sell_item(item: ItemData, amount: int = 1) -> bool:
	if not item.is_sellable:
		print(item.item_name, "cannot be sold yet")
		return false
	
	ItemInventory.add_coins(item.sell_price * amount)
	return true
