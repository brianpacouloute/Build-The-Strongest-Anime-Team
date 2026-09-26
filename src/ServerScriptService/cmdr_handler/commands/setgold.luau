return {
    Name = "setgold",
    Aliases = {},
    Description = "Set a player's gold",
    Group = "Admin",
    Args = {
        {
            Type = "number",
            Name = "amount",
            Description = "Gold to set",
        },
        {
            Type = "player",
            Name = "player",
            Description = "Who to set gold for",
            Optional = true,
        },
    },
}
