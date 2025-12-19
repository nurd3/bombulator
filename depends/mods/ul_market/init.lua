bombulator.register_nodes {
    ["ul_market:tradeinator"] = { chance = 1.0 },
    ["ul_market:tradeinator_rare"] = { chance = 1.0 },
    ["ul_market:tradeinator_super"] = { chance = 1.0 },
}

bombulator.register_entities {
    ["ul_market:npc"] = { chance = 1.0 },
}

bombulator.register_bombulation("bombulator:election", {
    interval = 60.0,
    global = ul_market.election
})