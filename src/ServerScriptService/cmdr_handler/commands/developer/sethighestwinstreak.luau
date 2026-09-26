return {
    Name = "sethighestwinstreak",
    Aliases = {},
    Description = "Set a player's highest winstreak",
    Group = "Developer",
    Args = {
        {
            Type = "number",
            Name = "amount",
            Description = "Highest winstreak to set",
        },
        {
            Type = "player",
            Name = "player",
            Description = "Who to set highest winstreak for",
            Optional = true,
        },
    },
}
