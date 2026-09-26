return {
    Name = "setwinstreak",
    Aliases = {},
    Description = "Set a player's winstreak",
    Group = "Admin",
    Args = {
        {
            Type = "player",
            Name = "player",
            Description = "Who to set winstreak for",
        },
        {
            Type = "number",
            Name = "amount",
            Description = "Winstreak to set",
        },
    },
}
