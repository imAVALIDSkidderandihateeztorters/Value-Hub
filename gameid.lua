local gameid = 127657182941129


if game.PlaceId ~= gameid then
    for _, player in ipairs(game.Players:GetPlayers()) do
        player:Kick("This script only works in Arena Royale.")
    end
    return
end

print("This script only works in Arena Royale.")
