local instance_handler = require(game.ServerScriptService.instance_handler)

instance_handler.functions.connect_signal(nil, "player_added", game.Players.PlayerAdded, instance_handler.functions.player_added)
instance_handler.functions.connect_signal(nil, "player_removed", game.Players.PlayerRemoving, instance_handler.functions.player_removed)

instance_handler.functions.table_init()



