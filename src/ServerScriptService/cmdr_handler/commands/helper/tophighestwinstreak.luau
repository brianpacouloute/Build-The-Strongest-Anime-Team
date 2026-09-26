return {
    Name = "tophighestwinstreak",
    Aliases = { },
    Description = "Show the top highest winstreak leaderboard",
    Group = "Helper",
    Args = {
        {
            Type = "number",
            Name = "count",
            Description = "How many players to show",
            Optional = true,
            Default = 10,
        },
    },
}
