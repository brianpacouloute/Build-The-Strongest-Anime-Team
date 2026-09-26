return {
    Name = "setwins",
    Aliases = {},
    Description = "Set a player's wins",
    Group = "Admin",
    Args = {
        {
            Type = "number",
            Name = "amount",
            Description = "Wins to set",
        },
        {
            Type = "player",
            Name = "player",
            Description = "Who to set wins for",
            Optional = true,
        },
    },
}
