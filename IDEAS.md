Have both spawn and despawn tile apparent at a time, have the start tile have
an arrow so you can survive if you go back onto it. This could be a point
bonus.

Refactor the GameBoard class to be a node in the Game scene tree and contain
the data of the entire grid (all placeable tiles as well as where the start and
end tiles are). This would remove the need to pass around coordinates so much
and recalculate board state information.
