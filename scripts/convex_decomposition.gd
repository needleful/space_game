@tool extends EditorScript

var mesh_path := NodePath("garage2")
var debug_mesh := NodePath("debug_mesh")

var vertex_to_id : Dictionary = {}
var vertices : PackedVector3Array = []

var face_vertices: Array[PackedInt32Array] = []
var face_normals: PackedVector3Array = []
var edge_faces: Array[PackedInt32Array] = []
var edge_vertices: Array[PackedInt32Array] = []

const EPSILON = 1e-2

func _run():
	var meshInst = get_scene().get_node(mesh_path)
	if !meshInst or !meshInst.mesh:
		print_debug("Node was not a MeshInstance3D or had no mesh: ", mesh_path)
		return
	
	var debug := ImmediateMesh.new()
	var debugMi = get_scene().get_node(debug_mesh)
	debugMi.mesh = debug
	
	parse_mesh(meshInst.mesh)
	print(" Vertices: ", vertices.size())
	print(" Edges: ", edge_faces.size())
	print(" Faces: ", face_vertices.size())
	
	var shapes := []
	var notch_edges:PackedInt32Array = []
	for e in edge_vertices.size():
		var faces:PackedInt32Array = edge_faces[e]
		if faces.size() != 2:
			# Not messing with it
			#notch_edges.append(e)
			continue
		# Determine if it's a notch
		var v0 := edge_vertices[e][0]
		var v1 := edge_vertices[e][1]
		var face0 := faces[0]
		var face1 := faces[1]
		var vf0: int
		var vf1: int
		for vf in 3:
			var face_vert = face_vertices[face0][vf]
			if face_vert != v0 and face_vert != v1:
				vf0 = face_vert
		for vf in 3:
			var face_vert = face_vertices[face1][vf]
			if face_vert != v0 and face_vert != v1:
				vf1 = face_vert
		var edir := (vertices[v1] - vertices[v0]).normalized()
		var fdir0 = (vertices[vf0] - vertices[v0]).slide(edir).normalized()
		var fdir1 = (vertices[vf1] - vertices[v0]).slide(edir).normalized()
		var fn0 := face_normals[face0].slide(edir).normalized()
		var fn1 := face_normals[face1].slide(edir).normalized()
		var bisect := (fn0 + fn1).normalized()
		var angle = fdir0.angle_to(bisect) + fdir1.angle_to(bisect)
		if angle + EPSILON < PI:
			notch_edges.append(e)
	print("Notch edges: ", notch_edges.size())
	debug.clear_surfaces()
	if notch_edges.size() > 0:
		debug.surface_begin(Mesh.PRIMITIVE_LINES)
		for n in notch_edges:
			debug.surface_add_vertex(vertices[edge_vertices[n][0]])
			debug.surface_add_vertex(vertices[edge_vertices[n][1]])
		debug.surface_end()

func parse_mesh(mesh: Mesh):
	var face_verts := mesh.get_faces()
	for face in face_verts.size()/3:
		face_vertices.append(PackedInt32Array())
		var f = face*3
		var v0 = face_verts[f]
		var v1 = face_verts[f+1]
		var v2 = face_verts[f+2]
		face_normals.append((v2 - v0).cross(v1 - v0).normalized())
		var vid := PackedInt32Array()
		for v in [v0, v1, v2]:
			if !(v in vertex_to_id):
				var id = vertices.size()
				vertex_to_id[v] = id
				vid.append(id)
				vertices.append(v)
			else:
				vid.append(vertex_to_id[v])
			face_vertices[face].append(vid[vid.size() - 1])
		var edge0:PackedInt32Array = [vid[0], vid[1]]
		var edge1:PackedInt32Array = [vid[1], vid[2]]
		var edge2:PackedInt32Array = [vid[2], vid[0]]
		for e1 in [edge0, edge1, edge2]:
			var edge_index := -1
			if e1[0] > e1[1]:
				var tmp = e1[0]
				e1[0] = e1[1]
				e1[1] = tmp
			for eindex in edge_vertices.size():
				var e2 := edge_vertices[eindex]
				if e1[0] == e2[0] and e1[1] == e2[1]:
					edge_index = eindex
					break
			if edge_index == -1:
				edge_vertices.append(e1)
				edge_faces.append(PackedInt32Array())
				edge_index = edge_vertices.size() - 1
			edge_faces[edge_index].append(face)
