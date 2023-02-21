# Minetest Sponge mod
## Water-removing sponges for Minetest.

Created by Benjie/fiftysix/56 2018-08-27 - Last updated 2023-02-21
Copyright Benjie 2018-2023

[Forum topic](https://forum.minetest.net/viewtopic.php?f=9&t=20729)
[Download from ContentDB](https://content.minetest.net/packages/FiftySix/sponge/)

Soggy sponges can rarely be found deep in the sea where the darkness begins.
These can be cooked into dry sponges, and then placed near a liquid to remove an area of it
They will hold the water away until they are removed.
This will cause them to become soggy, so to use them again they have to be cooked.

### How it works:
* Sponges create a diameter 9 sphere of air-like nodes that water can't flow through (checks for protection).
* If sponges have cleared more than 3 nodes of liquid, they become soggy sponges.
* Removing a sponge or soggy sponge will turn a diameter 9 sphere of air-like nodes back into air, as long as they are not in the area of another sponge.
*(Air-like nodes can be removed in protection by removing a sponge outside the protection, they are not meant to be permanent)*

### Options:
The mod should be most enjoyable by leaving all options at their default values.

**Replace air nodes** (sponge_replace_air_nodes): boolean, default true
Causes sponges not to replace air with water blocking airlike nodes. Disabling this may cause unusual behaviour with flowing water.

**Group list** (sponge_group_list): list, default: water
List of group names as group1,group2,... (common groups are water, liquid and lava)
See "Group list type" (sponge_group_list_type) for the behaviour of this list.

**Group list type** (sponge_group_list_type): multi-choice, default whitelist_source
If the groups in the group list should be treated as a whitelist or blacklist for removing liquids.
The *_source variants will remove all flowing liquids regardless of the list.

**Radius** (sponge_radius): number, default 4.5
Radius of the sphere or cube of liquid that gets removed.

**Sphere shape** (sponge_shape_sphere): boolean, default true
Whether to use a sphere shape to remove liquids.

**Replace with air** (sponge_replace_with_air): boolean, default false
Replace liquids with air instead of liquid blocking nodes.
This causes water to flow back immediately after placing the sponge.
