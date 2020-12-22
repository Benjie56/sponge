# Minetest sponge mod
## Water-removing sponges for Minetest.

made by Benjie/Fiftysix - 27/8/18
updated 22/12/20

[Forum topic](https://forum.minetest.net/viewtopic.php?f=9&t=20729)

Soggy sponges can rarely be found deep in the sea where the darkness begins.
These can be cooked into dry sponges, and then placed near a liquid to remove an area of it
They will hold the water away until they are removed.
This will cause them to become soggy, so to use them again they have to be cooked.

### How it works:
* Sponges create a 9x9 area of air-like nodes that water can't flow through (checks for protection).
* If sponges have cleared more than 3 nodes of liquid, they become soggy sponges.
* Removing a sponge or soggy sponge will turn a 9x9 area of air-like nodes back into air, as long as they are not in the area of another sponge.
*(Air-like nodes can be removed in protection by removing a sponge outside the protection, they are not meant to be permanent)*
