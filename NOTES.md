# General

- `NavigationPolygonInstance` there seems to be [a bug](https://github.com/godotengine/godot/issues/38204#issuecomment-678620211) with `NavigationPolygonInstance` when making polygons from outlines

# FTL

- Grid movement with large grids
- Grid spreading fire **not fun**

# Tips

- To duplicate root node in a scene use _Right Click > Merge From Scene_
- Use white sprite to tint it for fast coloring
- Positive rotation turns right
- Connect signals with default binds (true/false eg.)
- Implementation details are dictated by the scope of the project. For example, in our case, path finding is constructed so that units move to closest available positions. In FTL this is implemented in a simpler way: units just move in predefined tile positions if available. In our case path finding might be influenced by positioning of computers in rooms that have specific placement and units have to go to them in order to be operated. We won't go this far, but this is something that has to be discussed in order to determine the implementation details.

## Doors

Encountered issues:

- Timing when multiple units traversing the same door.
- Simple mechanic with lots of corner cases due to timing.
