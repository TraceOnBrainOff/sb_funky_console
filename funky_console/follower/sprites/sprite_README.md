###How to add sprites:
1. Make a new folder inside the current folder (/funkyBot/follower/sprites)
    It will serve as the name for the sprite
2. Inside the folder, create a new file called sprite.json (has to be this exact name), and inside, add an empty array with a sole string for the drawable. For example:

[
    "?setcolor..."
]

3. Save, restart the game if it's already opened and it's all done.

Note: If the follower no longer appears because of a drawable issue, revert to a failsafe one with "followerSetSprite example"