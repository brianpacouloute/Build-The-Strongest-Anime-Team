return {
    Name = "setwinstreak",
    Aliases = {},
    Description = "Set a player's winstreak",
    Group = "Admin",
    Args = {
        {
            Type = "number",
            Name = "amount",
            Description = "Winstreak to set",
        },
        {
            Type = "player",
            Name = "player",
            Description = "Who to set winstreak for",
            Optional = true,
        },
    },
}
