Config = {}

-- Streaming radius (meters). Prop spawns when player is closer than this,
-- despawns when farther. ox_lib handles the distance checks (one grid thread).
Config.StreamRadius = 150.0

-- Static props placed on load. Each client builds this list on its own start,
-- so late joiners get them automatically. No server needed.
Config.Props = {
    -- { model = 'prop_barrel_01a', coords = vec3(100.0, 200.0, 30.0), heading = 90.0 },
    -- { model = 'prop_bench_01a',  coords = vec3(120.0, 210.0, 30.0), heading = 0.0 },

    -- With ox_target (optional). `target` = array of option tables:
    -- {
    --     model = 'prop_barrel_01a',
    --     coords = vec3(100.0, 200.0, 30.0),
    --     heading = 90.0,
    --     target = {
    --         {
    --             name = 'orvar_barrel_use',
    --             icon = 'fa-solid fa-hand',
    --             label = 'Use barrel',
    --             distance = 2.0,
    --             onSelect = function(entity)
    --                 print('used barrel', entity)
    --             end,
    --         },
    --     },
    -- },
}
