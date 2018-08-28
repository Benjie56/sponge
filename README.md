# Minetest sponge mod
## Water-removing sponges for Minetest.

made by Benjie/Fiftysix - 27/8/18

[Forum topic](https://forum.minetest.net/viewtopic.php?f=9&t=20729)

Soggy sponges are quite rare, found deep in the sea where it is dark (below -11).
These can be cooked into dry sponges, and then placed near a liquid to remove an area of it. They will hold the water away until they are removed.
They turn in to soggy sponges when used, so to use them again, they have to be cooked.

### How it works:
* sponges create a 9x9 area of air-like nodes that water can't flow through (checks for protection)
* if sponges have cleared more than 3 nodes of liquid, they become soggy sponges
* removing a sponge or soggy sponge will turn a 9x9 area of air-like nodes back into air. 
*(Air-like nodes can be removed in protection by removing a sponge outside the protection, they are not meant to be permanent)*
