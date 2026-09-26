return {
    Name = "topgold",
    Aliases = {},
    Description = "Show the top gold leaderboard",
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
