return {
    Name = "setgold",
    Aliases = {},
    Description = "Set a player's gold",
    Group = "Admin",
    Args = {
        {
            Type = "player",
            Name = "player",
            Description = "Who to set gold for",
        },
        {
            Type = "number",
            Name = "amount",
            Description = "Gold to set",
        },
    },
}
