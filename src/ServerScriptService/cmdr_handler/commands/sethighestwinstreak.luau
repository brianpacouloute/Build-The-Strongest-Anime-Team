return {
    Name = "sethighestwinstreak",
    Aliases = {},
    Description = "Set a player's highest winstreak",
    Group = "Admin",
    Args = {
        {
            Type = "player",
            Name = "player",
            Description = "Who to set highest winstreak for",
        },
        {
            Type = "number",
            Name = "amount",
            Description = "Highest winstreak to set",
        },
    },
}
