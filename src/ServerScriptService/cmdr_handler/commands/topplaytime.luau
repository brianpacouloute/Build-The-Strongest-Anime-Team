return {
    Name = "topplaytime",
    Aliases = {},
    Description = "Show the top playtime leaderboard",
    Group = "Admin",
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
