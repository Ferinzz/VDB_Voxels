package main

import "core:fmt"
import rl "vendor:raylib"
import "core:math/rand"
import rlgl "vendor:raylib/rlgl"

MAX_INSTANCES :: 30_000

main :: proc() {
	rl.InitWindow(1280,920,"bit voxel map")
	rl.SetTargetFPS(60)
	
	
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
	rl.DisableCursor()
	shader: = rl.LoadShader(rl.TextFormat("VDB/Shaders/lighting_instancing.vs"),
                               rl.TextFormat("VDB/Shaders/lighting.fs"));
							   
							   
	 // Get shader locations
    shader.locs[rl.ShaderLocationIndex.MATRIX_MVP] = rl.GetShaderLocation(shader, "mvp");
    shader.locs[rl.ShaderLocationIndex.VECTOR_VIEW] = rl.GetShaderLocation(shader, "viewPos");
	shader.locs[rl.ShaderLocationIndex.MATRIX_MODEL] = i32(rl.GetShaderLocationAttrib(shader, "instanceTransform"))

    // Set shader value: ambient light level
    //ambientLoc: i32 = rl.GetShaderLocation(shader, "ambient");
	//value:=[4]f32{ 0.2, 0.2, 0.2, 1.0 }
    //rl.SetShaderValue(shader, ambientLoc, raw_data(value[:]), .VEC4);

    // Create one light
    //CreateLight(LIGHT_DIRECTIONAL, (Vector3){ 50.0f, 50.0f, 0.0f }, Vector3Zero(), WHITE, shader);
	
	//CubitsMesh: rl.Mesh = rl.GenMeshCube(1, 1, 1)
	CubitsMesh:= rl.GenMeshPlane(1,1,1,1)
	

	myMat: rl.Material = rl.LoadMaterialDefault()
	myMat.shader = shader
	myMat.maps[rl.MaterialMapIndex.ALBEDO].color = rl.GREEN
	
	
	
	transforms := make([]rl.Matrix, MAX_INSTANCES)
	defer delete(transforms)

	//for i in 0..<MAX_INSTANCES {
	//	translation := rl.MatrixTranslate(f32(rl.GetRandomValue(-50, 50)), f32(rl.GetRandomValue(-50, 50)), f32(rl.GetRandomValue(-50, 50)))
	//	axis := rl.Vector3Normalize({f32(rl.GetRandomValue(0, 360)), f32(rl.GetRandomValue(0, 360)), f32(rl.GetRandomValue(0, 360))})
	//	angle := f32(rl.GetRandomValue(0, 10))*f32(rl.DEG2RAD)
	//	rotation := rl.MatrixRotate(axis, angle)
	//
	//	transforms[i] = rotation * translation
	//}
	
	matrixes: = make([dynamic]rl.Matrix)
	
	
			for &num in cube {
			num = rand.uint64()
		}
			
			z:int
			locy:int
			for num, it in cube {
					z=it>>4
					locy=it & (16-1)
					locy*=2
					for x in 0..<32{
						//check  If the last bit is true to know if odd. meaning we need to add a cube
						if 1 == (num>> u32(x)) & 1{
							addSides(&matrixes, f32(x),f32(locy),f32(z))
							//append(&matrixes, rl.MatrixTranslate(f32(x),f32(locy),f32(z)))
						}
					}
					
					//making two x loops separately allows us to have no extra mem allocs still need to subtract :/
					locy+=1
					for x in 32..<64{
						//check  If the last bit is true to know if odd. meaning we need to add a cube
						if 1 == (num>> u32(x)) & 1{
							addSides(&matrixes, f32(x)-32,f32(locy),f32(z))
							//append(&matrixes, rl.MatrixTranslate(f32(x)-32,f32(locy),f32(z)))
							
						}
					}
			}

	
	//rlgl.DisableBackfaceCulling()
	for(!rl.WindowShouldClose()){
		rl.UpdateCamera(&camera, .FIRST_PERSON)
		framecount+=1
		
		rl.SetShaderValue(shader, rl.ShaderLocationIndex(shader.locs[rl.ShaderLocationIndex.VECTOR_VIEW]), raw_data(camera.position[:]), .VEC3);
		
		if 1==framecount%300 {
		fmt.println(len(matrixes))
		clear(&matrixes)
		for &num in cube {
			num = rand.uint64()
		}
		
	for i in 0..<15 {
		z:int
		locy:int
		for num, it in cube {
				z=it>>4
				locy=it & (16-1)
				locy*=2
				for x in 0..<32{
					//check  If the last bit is true to know if odd. meaning we need to add a cube
					if 1 == (num>> u32(x)) & 1{
						addSides(&matrixes, f32(x),f32(locy),f32(z))
						//append(&matrixes, rl.MatrixTranslate(f32(x),f32(locy),f32(z)))
					}
				}
				
				//making two x loops separately allows us to have no extra mem allocs still need to subtract :/
				locy+=1
				for x in 32..<64{
					//check  If the last bit is true to know if odd. meaning we need to add a cube
					if 1 == (num>> u32(x)) & 1{
						addSides(&matrixes, f32(x)-32,f32(locy),f32(z))
						//append(&matrixes, rl.MatrixTranslate(f32(x)-32,f32(locy),f32(z)))
						
					}
				}
		}
			
	}
		
	}
			
	rl.BeginDrawing()

	rl.ClearBackground({132,75,99,1})
	rl.BeginMode3D(camera)
	
	rl.DrawGrid(100,.25)

	//rl.DrawCube({0,0,0},1,1,1,{125,125,125,252})

	//rlgl.EnableWireMode()
		rl.DrawMeshInstanced(CubitsMesh, myMat, raw_data(matrixes), i32(len(matrixes)))
	////TOP PLANE
	//{
	//translation := rl.MatrixTranslate(0,0.5,0)
	//
	//rl.DrawMesh(CubitsMesh, myMat, translation)
	//}
	////BOTTOM PLANE
	//{
	//	translation := rl.MatrixTranslate(0,-0.5,0)
	//	
	//	axis :=rl.Vector3Normalize([?]f32 {1,0,0})
	//	angle := 180*f32(rl.DEG2RAD)
	//	rotation := rl.MatrixRotate(axis, angle)
	//	transform:= translation * rotation
//
	//	rl.DrawMesh(CubitsMesh, myMat, transform)
	//}
	////LEFT PLANE
	//{
	//	translation := rl.MatrixTranslate(0,0,-0.5)
	//	axis :=rl.Vector3Normalize([?]f32 {1,0,0})
	//	angle := 270*f32(rl.DEG2RAD)
	//	rotation := rl.MatrixRotate(axis, angle)
	//	transform:= translation * rotation
	//	
	//	rl.DrawMesh(CubitsMesh, myMat, transform)
	//}
	////RIGHT PLANE
	//{
	//	translation := rl.MatrixTranslate(0,0,0.5)
	//	axis :=rl.Vector3Normalize([?]f32 {1,0,0})
	//	angle := 90*f32(rl.DEG2RAD)
	//	rotation := rl.MatrixRotate(axis, angle)
	//	transform:= translation * rotation
	//	
	//	rl.DrawMesh(CubitsMesh, myMat, transform)
	//}
	////FRONT PLANE
	//{
	//	translation := rl.MatrixTranslate(-0.5,0,0)
	//	axis :=rl.Vector3Normalize([?]f32 {0,0,1})
	//	angle := 90*f32(rl.DEG2RAD)
	//	rotation := rl.MatrixRotate(axis, angle)
	//	transform:= translation * rotation
	//	
	//	rl.DrawMesh(CubitsMesh, myMat, transform)
	//}
	////BACK PLANE
	//{
	//	translation := rl.MatrixTranslate(0.5,0,0)
	//	axis :=rl.Vector3Normalize([?]f32 {0,0,1})
	//	angle := 270*f32(rl.DEG2RAD)
	//	rotation := rl.MatrixRotate(axis, angle)
	//	transform:= translation * rotation
	//	
	//	rl.DrawMesh(CubitsMesh, myMat, transform)
	//}

	//addSides(&matrixes, 0,0,1)
	//for location in matrixes {
	//	rl.DrawMesh(CubitsMesh, myMat, location)
	//}
	//clear(&matrixes)
	rlgl.DisableWireMode()
	rl.EndMode3D()

	rl.DrawFPS(0,0)

	rl.EndDrawing()
	}
	
}

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