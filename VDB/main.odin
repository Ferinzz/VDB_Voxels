package main

import "core:fmt"
import rl "vendor:raylib"
import "core:math/rand"
import rlgl "vendor:raylib/rlgl"

MAX_INSTANCES :: 30_000

main :: proc() {

	//*****************************\\
	//*******WINDOW SETTINGS*******\\
	//*****************************\\
	rl.InitWindow(1280,920,"bit voxel map")
	//rl.SetTargetFPS(60)
	rl.DisableCursor()
	
	camera := rl.Camera3D{
		position = {-2,0.5,.75},
		target = {0,0,0},
		up = {0,1,0},
		fovy = 60,
		projection = .PERSPECTIVE,
	}
	
	cube:[512]u64

	GLSL_VERSION := 330
	counter:u32=0
	framecount:u32=0
	

	

	
	//transforms := make([]rl.Matrix, MAX_INSTANCES)
	//defer delete(transforms)
	//for i in 0..<MAX_INSTANCES {
	//	translation := rl.MatrixTranslate(f32(rl.GetRandomValue(-50, 50)), f32(rl.GetRandomValue(-50, 50)), f32(rl.GetRandomValue(-50, 50)))
	//	axis := rl.Vector3Normalize({f32(rl.GetRandomValue(0, 360)), f32(rl.GetRandomValue(0, 360)), f32(rl.GetRandomValue(0, 360))})
	//	angle := f32(rl.GetRandomValue(0, 10))*f32(rl.DEG2RAD)
	//	rotation := rl.MatrixRotate(axis, angle)
	//
	//	transforms[i] = rotation * translation
	//}
	
			

	


	//*****************************\\
	//*********SHADER SETUP********\\
	//*****************************\\
	shader: = rl.LoadShader(rl.TextFormat("VDB/Shaders/lighting_instancing.vs"),
                               rl.TextFormat("VDB/Shaders/lighting.fs"));
	
	 // Get shader locations
    shader.locs[rl.ShaderLocationIndex.MATRIX_MVP] = rl.GetShaderLocation(shader,
		 "mvp");
    shader.locs[rl.ShaderLocationIndex.VECTOR_VIEW] = rl.GetShaderLocation(shader,
		 "viewPos");
	shader.locs[rl.ShaderLocationIndex.MATRIX_MODEL] = i32(rl.GetShaderLocationAttrib(shader,
		 "instanceTransform"))
		
	myMat: rl.Material = rl.LoadMaterialDefault()
	myMat.shader = shader
	myMat.maps[rl.MaterialMapIndex.ALBEDO].color = rl.GREEN
	
	row:u64=4127498766
	row2:u64=4121234766
	
	
	//*****************************\\
	//*******CHUNK INIT SETUP******\\
	//*****************************\\
	//CubitsMesh: rl.Mesh = rl.GenMeshCube(1, 1, 1)
	CubitsMesh:= rl.GenMeshPlane(1,1,1,1)
	matrixes: = make([dynamic]rl.Matrix)
	for &num in cube {
		num = rand.uint64()
	}
	//parseChunk(cube[:], &matrixes)	


	//*********************************\\
	//*************GAME LOOP***********\\
	//*********************************\\
	//rlgl.DisableBackfaceCulling()
	for(!rl.WindowShouldClose()){
	rl.UpdateCamera(&camera, .FIRST_PERSON)
	framecount+=1
	
	rl.SetShaderValue(shader, rl.ShaderLocationIndex(shader.locs[rl.ShaderLocationIndex.VECTOR_VIEW]), raw_data(camera.position[:]), .VEC3);
	
	//Generate a new randomized chunk
	if 1==framecount%3000 {
		clear(&matrixes)
		for &num in cube {
			num = rand.uint64()
		}
		
		//take a u32, bitshift left -> xor original, gives placement of right side plane
		//do same with bitshift right for left side plane
		//row: u32 = rand.uint32()
		

		//inside:bool=false

		//for x in 0..<32{
		//	if (1 == (row >> u32(x)) & 1) && inside == false{
		//		inside=true
		//		addLeftPlane(&matrixes, f32(x),0,0)
		//		
		//	}
		//	if inside == true && (0 == (row >> u32(x)) & 1){
		//		inside=false
		//		addRightPlane(&matrixes, f32(x)-1,0,0)
		//		continue
		//	}
		//	if inside == true {addFrontBack(&matrixes, f32(x),0,0)}
		//}
		//inside=false
		//for x in 0..<32{
		//	if (1 == (row2 >> u32(x)) & 1) && inside == false{
		//		inside=true
		//		addLeftPlane(&matrixes, f32(x),1,0)
		//		
		//	}
		//	if inside == true && (0 == (row2 >> u32(x)) & 1){
		//		inside=false
		//		addRightPlane(&matrixes, f32(x)-1,1,0)
		//		continue
		//	}
		//	if inside == true {addFrontBack(&matrixes, f32(x),1,0)}
		//}

		//rightPlanes := (row<<1)
		//rightPlanes = rightPlanes~row
		////fmt.println(row)
		//for x in 0..<32{
		//	//check  If the last bit is true to know if odd. meaning we need to add a cube
		//	if 1 == (rightPlanes >> u32(x)) & 1{
		//		addLeftPlane(&matrixes, f32(x),0,0)
		//	}
		//}
		//leftPlanes := (row>>1)
		//leftPlanes = leftPlanes ~ row
		//for x in 0..<32{
		//	//check  If the last bit is true to know if odd. meaning we need to add a cube
		//	if 1 == (leftPlanes >> u32(x)) & 1{
		//		addRightPlane(&matrixes, f32(x),0,0)
		//	}
		//}
		//for x in 0..<32{
		//	//check  If the last bit is true to know if odd. meaning we need to add a cube
		//	if 1 == (row >> u32(x)) & 1{
		//		//fmt.println("true")
		//		addFrontBack(&matrixes, f32(x),0,0)
		//	}
		//}
		
		//for x in 0..<32{
		//	if 1 == (row>>u32(x)) & 1 {
		//		addSides(&matrixes, f32(x), 0, 0)
		//	}
		//}
		for i in 0..<15 {
			parseChunk(cube[:], &matrixes)
		}
		framecount = 1
	}
			
	rl.BeginDrawing()

	rl.ClearBackground({132,75,99,1})
	rl.BeginMode3D(camera)
	
	rl.DrawGrid(100,.5)

	//rlgl.EnableWireMode()

	//Draw instances of the chunk
	rl.DrawMeshInstanced(CubitsMesh, myMat, raw_data(matrixes), i32(len(matrixes)))
	


	//addSides(&matrixes, 0,0,1)
	//for location in matrixes {
	//	rl.DrawMesh(CubitsMesh, myMat, location)
	//}
	//clear(&matrixes)

	//rlgl.DisableWireMode()
	rl.EndMode3D()

	rl.DrawFPS(0,0)

	rl.EndDrawing()
	}
	//GAME LOOP END
	
}
//Main func end

//*****************************\\
//******UTILITY FUNCTIONS******\\
//*****************************\\
addSides :: proc (positions: ^[dynamic]rl.Matrix, x,y,z :f32) {
		//TOP PLANE
		{
			translation := rl.MatrixTranslate(x,y+0.5,z)
			append(positions, translation)
			
			}
			//BOTTOM PLANE
			{
				translation := rl.MatrixTranslate(x,y-0.5,z)
				
				axis :=rl.Vector3Normalize([?]f32 {1,0,0})
				angle := 180*f32(rl.DEG2RAD)
				rotation := rl.MatrixRotate(axis, angle)
				transform:= translation * rotation
				
				append(positions, transform)
			}
		//LEFT PLANE
		{
			translation := rl.MatrixTranslate(x,y,z-0.5)
			axis :=rl.Vector3Normalize([?]f32 {1,0,0})
			angle := 270*f32(rl.DEG2RAD)
			rotation := rl.MatrixRotate(axis, angle)
			transform:= translation * rotation
			
			append(positions, transform)
		}
		//RIGHT PLANE
		{
			translation := rl.MatrixTranslate(x,y,z+0.5)
			axis :=rl.Vector3Normalize([?]f32 {1,0,0})
			angle := 90*f32(rl.DEG2RAD)
			rotation := rl.MatrixRotate(axis, angle)
			transform:= translation * rotation
			
			append(positions, transform)
		}
		//FRONT PLANE
		{
			translation := rl.MatrixTranslate(x-0.5,y,z)
			axis :=rl.Vector3Normalize([?]f32 {0,0,1})
			angle := 90*f32(rl.DEG2RAD)
			rotation := rl.MatrixRotate(axis, angle)
			transform:= translation * rotation
			
			append(positions, transform)
		}
		//BACK PLANE
		{
			translation := rl.MatrixTranslate(x+0.5,y,z)
			axis :=rl.Vector3Normalize([?]f32 {0,0,1})
			angle := 270*f32(rl.DEG2RAD)
			rotation := rl.MatrixRotate(axis, angle)
			transform:= translation * rotation
			
			append(positions, transform)
		}

}

addRightPlane :: proc(positions: ^[dynamic]rl.Matrix, x,y,z :f32) {
	
	{
		translation := rl.MatrixTranslate(x+0.5,y,z)
		axis :=rl.Vector3Normalize([?]f32 {0,0,1})
		angle := 270*f32(rl.DEG2RAD)
		rotation := rl.MatrixRotate(axis, angle)
		transform:= translation * rotation
		
		append(positions, transform)
	}

}
addLeftPlane :: proc(positions: ^[dynamic]rl.Matrix, x,y,z :f32) {
	
	//FRONT PLANE
	{
		translation := rl.MatrixTranslate(x-0.5,y,z)
		axis :=rl.Vector3Normalize([?]f32 {0,0,1})
		angle := 90*f32(rl.DEG2RAD)
		rotation := rl.MatrixRotate(axis, angle)
		transform:= translation * rotation
		
		append(positions, transform)
	}

}

addFrontBack :: proc(positions: ^[dynamic]rl.Matrix, x,y,z :f32) {
		//LEFT PLANE
		{
			translation := rl.MatrixTranslate(x,y,z-0.5)
			axis :=rl.Vector3Normalize([?]f32 {1,0,0})
			angle := -90*f32(rl.DEG2RAD)
			rotation := rl.MatrixRotate(axis, angle)
			transform:= translation * rotation

			append(positions, transform)
		}
		//RIGHT PLANE
		{
			translation := rl.MatrixTranslate(x,y,z+0.5)
			axis :=rl.Vector3Normalize([?]f32 {1,0,0})
			angle := 90*f32(rl.DEG2RAD)
			rotation := rl.MatrixRotate(axis, angle)
			transform:= translation * rotation
			
			append(positions, transform)
		}
}

addTop :: proc(positions: ^[dynamic]rl.Matrix, x,y,z :f32) {

		//TOP PLANE
		{
			translation := rl.MatrixTranslate(x,y+0.5,z)
			append(positions, translation)
		}
}

addBottom :: proc(positions: ^[dynamic]rl.Matrix, x,y,z :f32) {

		//BOTTOM PLANE
		{
			translation := rl.MatrixTranslate(x,y-0.5,z)
			
			axis :=rl.Vector3Normalize([?]f32 {1,0,0})
			angle := 180*f32(rl.DEG2RAD)
			rotation := rl.MatrixRotate(axis, angle)
			transform:= translation * rotation
			
			append(positions, transform)
		}
}

addFront :: proc(positions: ^[dynamic]rl.Matrix, x,y,z :f32) {
	
		//RIGHT PLANE
		{
			translation := rl.MatrixTranslate(x,y,z+0.5)
			axis :=rl.Vector3Normalize([?]f32 {1,0,0})
			angle := 90*f32(rl.DEG2RAD)
			rotation := rl.MatrixRotate(axis, angle)
			transform:= translation * rotation
			
			append(positions, transform)
		}
}

addBack :: proc(positions: ^[dynamic]rl.Matrix, x,y,z :f32) {
	
		//LEFT PLANE
		{
			translation := rl.MatrixTranslate(x,y,z-0.5)
			axis :=rl.Vector3Normalize([?]f32 {1,0,0})
			angle := -90*f32(rl.DEG2RAD)
			rotation := rl.MatrixRotate(axis, angle)
			transform:= translation * rotation
			
			append(positions, transform)
		}
}

parseChunk :: proc(chunk: []u64, matrixes: ^[dynamic]rl.Matrix) {
	nextRow:u64
	z:int
	locy:int
	inside:bool
	for num, it in chunk {
		inside = false
		z = it>>4
		locy = it & (16-1)
		locy *= 2
		if it<len(chunk)-1 {
		nextRow = chunk[it+1]}
		
		
		//Too cull front/back planes ~xor with other row then & with original to only have 
		//the faces that matter. Other faces will be zeroed
		//keep the xor and I can do the faces of the next row because I already have the 
		//change.
		//loop would be checking first half with second half. Taking second half to check next
		//row. Check next row first half with last half of this row.
		//If last index, only check first half with second half.
		//Can use processor optimistic calcs to optimize away the bool check..
		//It would kill itself due to buff overflow?
		
		//right plane example
		//10110001
		//<<
		//01100010
		//xor
		//10110001
		//=11010011
		//&
		//10110001
		//=10010001
		
		//Bottom plane example
		//10110001 top row
		//xor
		//00010010 bottom row
		//=10100011
		//&
		//10110001
		//=10100001

		//Could rewrite and reduce instruction number by
		//-duplicating second half on a single u64
		//-put next row and first half on the same u64
		//-Results can be read from start to finish as the same direction of plane
		//-Would need to add an if for when it gets passed 32 bits
		//temp1:=num>>32
		secondhalf:=num>>32
		
		xorcheck:=secondhalf~num
		

		for x in 0..<32 {
			temp := num & xorcheck
			if (1 == (temp >> u32(x)) & 1){
				addTop(matrixes, f32(x),f32(locy),f32(z))
			}
		}
		
		for x in 0..<32 {
			temp := secondhalf & xorcheck
			if (1 == (temp >> u32(x)) & 1){
				addBottom(matrixes, f32(x),f32(locy)+1,f32(z))
			}
		}
		
		if it < len(chunk)-1 {
		xorcheck = secondhalf ~ nextRow

		for x in 0..<32 {
			temp := secondhalf & xorcheck
			if (1 == (temp >> u32(x)) & 1){
				addTop(matrixes, f32(x),f32(locy)+1,f32(z))
			}
		}
		
		if locy < 30 {
		for x in 0..<32 {
			temp := nextRow & xorcheck
			if (1 == (temp >> u32(x)) & 1){
				addBottom(matrixes, f32(x),f32(locy)+2,f32(z))
			}
		}
		}
		}

		//Z axis check can be done in the same way as Y axis
		//get the value one Z index over Can make a const value out of 1 << 4
		//Shouldn't need to split sections per row, since the row order aligns per u64
		//
		
		{
		secondRow:u64
		//num
		if z<31{
		offset:u64:1<<4
		secondRow = chunk[it+int(offset)]
		zXorCheck := secondRow ~ num
		for x in 0..<32 {
			temp:= zXorCheck & num
			//fmt.println(temp >> u32(x))
			if (1 == (temp >> u32(x)) & 1) {
			addFront(matrixes, f32(x),f32(locy),f32(z))
			}
		}
		for x in 32..<64 {
			temp:= zXorCheck & num
			if (1 == (temp >> u32(x)) & 1) {
			addFront(matrixes, f32(x)-32,f32(locy)+1,f32(z))
			}
		}
		for x in 0..<32 {
			temp:= zXorCheck & secondRow
			if (1 == (temp >> u32(x)) & 1) {
			addBack(matrixes, f32(x),f32(locy),f32(z+1))
			}
		}
		for x in 32..<64 {
			temp:= zXorCheck & secondRow
			if (1 == (temp >> u32(x)) & 1) {
			addBack(matrixes, f32(x)-32,f32(locy)+1,f32(z+1))
			}
		}
		}
		}

		for x in 0..<32{
			//check  If the last bit is true to know if odd. meaning we need to add a cube
			//if 1 == (num>> u32(x)) & 1{
			//	addSides(matrixes, f32(x),f32(locy),f32(z))
			//	//append(&matrixes, rl.MatrixTranslate(f32(x),f32(locy),f32(z)))
			//}
			if inside == false && (1 == (num >> u32(x)) & 1) {
				inside=true
				addLeftPlane(matrixes, f32(x),f32(locy),f32(z))
				
			}
			if inside == true && (0 == (num >> u32(x)) & 1){
				inside=false
				addRightPlane(matrixes, f32(x)-1,f32(locy),f32(z))
				continue
			}
			//if inside == true {addFrontBack(matrixes, f32(x),f32(locy),f32(z))}
			
		}

		
		//making two x loops separately allows us to have no extra mem allocs still need to subtract :/
		inside=false
		locy+=1
		for x in 32..<64{
			//check  If the last bit is true to know if odd. meaning we need to add a cube
			//if 1 == (num>> u32(x)) & 1{
			//	addSides(matrixes, f32(x)-32,f32(locy),f32(z))
			//	//append(&matrixes, rl.MatrixTranslate(f32(x)-32,f32(locy),f32(z)))
			//	
			//}
			if (1 == (num >> u32(x)) & 1) && inside == false{
				inside=true
				addLeftPlane(matrixes, f32(x)-32,f32(locy),f32(z))
				
			}
			if inside == true && (0 == (num >> u32(x)) & 1){
				inside=false
				addRightPlane(matrixes, f32(x)-1-32,f32(locy),f32(z))
				continue
			}
			//if inside == true {addFrontBack(matrixes, f32(x)-32,f32(locy),f32(z))}
		}
	}
}