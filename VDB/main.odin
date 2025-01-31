package main

import "core:fmt"
import rl "vendor:raylib"
import "core:math/rand"
import rlgl "vendor:raylib/rlgl"

MAX_INSTANCES :: 30_000

main :: proc() {
	rl.InitWindow(1280,920,"bit voxel map")
	//rl.SetTargetFPS(60)
	
	
	camera := rl.Camera3D{
		position = {-2,0.5,1},
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
	shader: = rl.LoadShader(rl.TextFormat("C:/Odin_programs/VDB/Shaders/lighting_instancing.vs"),
                               rl.TextFormat("C:/Odin_programs/VDB/Shaders/lighting.fs"));
							   
							   
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
	
	CubitsMesh: rl.Mesh = rl.GenMeshCube(1, 1, 1)
	//CubitsModel: rl.Model = rl.LoadModelFromMesh(CubitsMesh)
	//CubitsModel.materials[0].maps[rl.MaterialMapIndex.ALBEDO].color = rl.GREEN
	
	myMat: rl.Material = rl.LoadMaterialDefault()
	myMat.shader = shader
	myMat.maps[rl.MaterialMapIndex.ALBEDO].color = rl.GREEN
	
	
	
	transforms := make([]rl.Matrix, MAX_INSTANCES)
	defer delete(transforms)

	for i in 0..<MAX_INSTANCES {
		translation := rl.MatrixTranslate(f32(rl.GetRandomValue(-50, 50)), f32(rl.GetRandomValue(-50, 50)), f32(rl.GetRandomValue(-50, 50)))
		axis := rl.Vector3Normalize({f32(rl.GetRandomValue(0, 360)), f32(rl.GetRandomValue(0, 360)), f32(rl.GetRandomValue(0, 360))})
		angle := f32(rl.GetRandomValue(0, 10))*f32(rl.DEG2RAD)
		rotation := rl.MatrixRotate(axis, angle)
	
		transforms[i] = rl.MatrixMultiply(rotation, translation)
	}
	myMatrix: = rl.MatrixTranslate(0,0,0)
	
	myMatrix2: = rl.MatrixTranslate(3,0,0)
	fmt.println(myMatrix2)
	//matrixes: [dynamic]rl.Matrix  
	matrixes: = make([dynamic]rl.Matrix)
	//matrixes[0]=myMatrix
	//matrixes[1]=myMatrix2
	//append(&matrixes,{myMatrix,myMatrix2})
	matrixeses:  = raw_data(matrixes[:])
	
			for &num in cube {
			num = rand.uint64()
		}
					//so far I can only do 18 of these :(
			z:int
			locy:int
			for num, it in cube {
					z=it>>4
					locy=it & (16-1)
					locy*=2
					for x in 0..<32{
						//check  If the last bit is true to know if odd. meaning we need to add a cube
						if 1 == (num>> u32(x)) & 1{
							append(&matrixes, rl.MatrixTranslate(f32(x),f32(locy),f32(z)))
						}
					}
					
					//making two x loops separately allows us to have no extra mem allocs still need to subtract :/
					locy+=1
					for x in 32..<64{
						//check  If the last bit is true to know if odd. meaning we need to add a cube
						if 1 == (num>> u32(x)) & 1{
							append(&matrixes, rl.MatrixTranslate(f32(x)-32,f32(locy),f32(z)))
							
						}
					}
			}
	
	
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
		for i in 0..<50{
			//so far I can only do 18 of these :(
			z:int
			locy:int
			for num, it in cube {
					z=it>>4
					locy=it & (16-1)
					locy*=2
					for x in 0..<32{
						//check  If the last bit is true to know if odd. meaning we need to add a cube
						if 1 == (num>> u32(x)) & 1{
							append(&matrixes, rl.MatrixTranslate(f32(x),f32(locy),f32(z)))
						}
					}
					
					//making two x loops separately allows us to have no extra mem allocs still need to subtract :/
					locy+=1
					for x in 32..<64{
						//check  If the last bit is true to know if odd. meaning we need to add a cube
						if 1 == (num>> u32(x)) & 1{
							append(&matrixes, rl.MatrixTranslate(f32(x)-32,f32(locy),f32(z)))
							
						}
					}
			}
			}
		}
		

			
		rl.BeginDrawing()
		rl.ClearBackground({132,75,99,1})
		rl.BeginMode3D(camera)
		
		rl.DrawGrid(100,.25)
		rl.DrawMeshInstanced(CubitsMesh, myMat, raw_data(matrixes), i32(len(matrixes)))
		
		rl.EndMode3D()
		rl.DrawFPS(0,0)
		rl.EndDrawing()
	}
	
}