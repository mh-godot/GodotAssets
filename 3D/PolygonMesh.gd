extends MeshInstance


export var depth = 1.0
export(PoolVector2Array) var points setget set_points, get_points
var surface_tool = SurfaceTool.new()

func set_points(p):
	points = p
	build()

func get_points():
	return points

func v2Cross(a,b):
	return a.x * b.y - a.y * b.x

func _get_area():
	var n = points.size();

	var A = 0.0;

	var q = 0
	var p = n - 1
	while(q < n):
		A += v2Cross(points[p],points[q])
		p = q
		q += 1

	return A * 0.5;

func build():
	surface_tool.clear()
	if(points == null or points.size() < 3):
		return



	var faces = Geometry.triangulate_polygon(points)
	if(faces.size() == 0):
		return

	var right_hand = _get_area() > 0

	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.add_smooth_group(false)
	for i in range(0,faces.size(),3):
		_build_side_triangle([faces[i],faces[i+1],faces[i+2]])
	for i in range(points.size()):
		_build_outer_triangle(i,(i+1) % points.size(),right_hand)

	surface_tool.index()
	surface_tool.generate_normals()
	mesh = surface_tool.commit()

func _build_outer_triangle(a,b, right_hand):
	var z = depth/2.0


	if(right_hand):
		surface_tool.add_vertex(Vector3(points[a].x,points[a].y,z))
		surface_tool.add_vertex(Vector3(points[b].x,points[b].y,z))
		surface_tool.add_vertex(Vector3(points[a].x,points[a].y,-z))

		surface_tool.add_vertex(Vector3(points[b].x,points[b].y,z))
		surface_tool.add_vertex(Vector3(points[b].x,points[b].y,-z))
		surface_tool.add_vertex(Vector3(points[a].x,points[a].y,-z))
	else:
		surface_tool.add_vertex(Vector3(points[a].x,points[a].y,z))
		surface_tool.add_vertex(Vector3(points[a].x,points[a].y,-z))
		surface_tool.add_vertex(Vector3(points[b].x,points[b].y,z))

		surface_tool.add_vertex(Vector3(points[b].x,points[b].y,z))
		surface_tool.add_vertex(Vector3(points[a].x,points[a].y,-z))
		surface_tool.add_vertex(Vector3(points[b].x,points[b].y,-z))


func _build_side_triangle(face):
	var z = depth/2.0
	var a = points[face[0]]
	var b = points[face[1]]
	var c = points[face[2]]

	surface_tool.add_vertex(Vector3(c.x,c.y,z))
	surface_tool.add_vertex(Vector3(b.x,b.y,z))
	surface_tool.add_vertex(Vector3(a.x,a.y,z))

	if(depth > 0.0):
		surface_tool.add_vertex(Vector3(a.x,a.y,-z))
		surface_tool.add_vertex(Vector3(b.x,b.y,-z))
		surface_tool.add_vertex(Vector3(c.x,c.y,-z))
	pass
