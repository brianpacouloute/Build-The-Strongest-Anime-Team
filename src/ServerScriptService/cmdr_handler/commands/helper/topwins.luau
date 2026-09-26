return {
    Name = "topwins",
    Aliases = {},
    Description = "Show the top wins leaderboard",
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
