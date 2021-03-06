//------------------------------------------- Defines -------------------------------------------//

#define Pi 3.14159265

//------------------------------------- Top Level Variables -------------------------------------//

// Top level variables can and have to be set at runtime

// Matrices for 3D perspective projection 
float4x4 View, Projection, World;

//---------------------------------- Input / Output structures ----------------------------------//

// Each member of the struct has to be given a "semantic", to indicate what kind of data should go in
// here and how it should be treated. Read more about the POSITION0 and the many other semantics in 
// the MSDN library
struct VertexShaderInput
{
	float4 Position3D : POSITION0;
	float4 color : COLOR0;
	float3 normal : NORMAL0;
	float2 TextureCoordinate : TEXCOORD0;
};

// The output of the vertex shader. After being passed through the interpolator/rasterizer it is also 
// the input of the pixel shader. 
// Note 1: The values that you pass into this struct in the vertex shader are not the same as what 
// you get as input for the pixel shader. A vertex shader has a single vertex as input, the pixel 
// shader has 3 vertices as input, and lets you determine the color of each pixel in the triangle 
// defined by these three vertices. Therefor, all the values in the struct that you get as input for 
// the pixel shaders have been linearly interpolated between there three vertices!
// Note 2: You cannot use the data with the POSITION0 semantic in the pixel shader.
struct VertexShaderOutput
{
	float4 Position2D : POSITION0;
	float4 Position3D : TEXCOORD0;
	float3 normal : TEXCOORD1;
	float2 TextureCoordinate : TEXCOORD2; 
};

//------------------------------------------ Functions ------------------------------------------//

// Coloring using normals is implemented here
// It takes the normal from the vertexshader output 
float4 NormalColor(float3 normal)
{
	//return float4(0, 0, 0, 1);
	float4 color = float4(1,0,0,1);
	color.rgb = normal;
	return color;
}

// Implement the Procedural texturing assignment here
float3 ProceduralColor(VertexShaderOutput input)
{	
	if (sin(Pi*input.Position3D.x/0.20) > 0)
	{
		if (sin(Pi*input.Position3D.y/0.20) > 0)
			return input.normal;
		else
			return -input.normal;
	}
	else
	{
		if (sin(Pi*input.Position3D.y/0.20) > 0)
			return -input.normal;
		else
			return input.normal;
	}
}

/// z fighting

//---------------------------------------- Technique: Simple ----------------------------------------//

VertexShaderOutput SimpleVertexShader(VertexShaderInput input)
{
	// Allocate an empty output struct
	VertexShaderOutput output = (VertexShaderOutput)0;

	// Do the matrix multiplications for perspective projection and the world transform
	float4 worldPosition = mul(input.Position3D, World);
    float4 viewPosition  = mul(worldPosition, View);

	output.Position2D    = mul(viewPosition, Projection);
	output.Position3D    = input.Position3D;
	output.normal = input.normal;
	output.TextureCoordinate = input.TextureCoordinate;

	return output;
}

float4 SimplePixelShader(VertexShaderOutput input) : COLOR0
{
	input.normal = ProceduralColor(input);
	float4 color = NormalColor(input.normal);
	return color;
}

technique Simple
{
	pass Pass0
	{
		VertexShader = compile vs_2_0 SimpleVertexShader();
		PixelShader  = compile ps_2_0 SimplePixelShader();
	}
}