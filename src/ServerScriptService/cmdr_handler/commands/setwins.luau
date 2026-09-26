return {
    Name = "setwins",
    Aliases = {},
    Description = "Set a player's wins",
    Group = "Admin",
    Args = {
        {
            Type = "player",
            Name = "player",
            Description = "Who to set wins for",
        },
        {
            Type = "number",
            Name = "amount",
            Description = "Wins to set",
        },
    },
}
