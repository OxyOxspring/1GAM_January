// © 2009 - 3Point Studios -
// http://www.3pointstudios.com
// Code: Christoph Kubisch - christoph.kubisch@3pointstudios.com
// Design: Per Abrahamsen  - perna@3pointstudios.com

// The software MAY NOT BE RESOLD, NOR REDISTRIBUTED
// by any means of commercial exploitation. USE AT OWN RISK!
// FOR COMMERCIAL USE of any kind, a COMMERCIAL LICENSE MUST BE 
// ACQUIRED from 3Point Studios.
//
// Standard Shader 1.0
//
// Requirements:
//	Shader Model 3 capable card (Nvidia GeForce 6, Radeon X1300)
//	for SRGB version (default true)
//		SRGB Texture capable card
//
// Note:
//	Not optimized for speed, dont use for runtime work
//	Intended to use indirectly with the 3dsmax "3Point Shader" 
//	material-plugin. 
//


string ParamID = "0x003";
/*
float Script : STANDARDSGLOBAL <
	string UIWidget = "none";
	string ScriptClass = "object";
	string ScriptOrder = "standard";
	string ScriptOutput = "color";
	string Script = "Technique=Full_PS3;";
> = 1.0; // version #
*/
#if defined(_3DSMAX_)
	#include "3ps-maxversion.fxh"
#endif

	// faster load times
#define PRECOMPILED

///////////////////////////////////////
// Shader Settings 
// changes only valid in non-PRECOMPILED state

// technique related

	// shadows can be globally enabled/disabled
#ifndef SHADOW_STANDARD
#define SHADOW_STANDARD		true
#endif
	// 1 HARD, 2 SOFT, 3 AREA
	// make sure to set G3P_ShaderHardShadow and/or G3P_ShaderAreaShadow
	// for proper UI code as well
#ifndef SHADOW_PREFERTYPE
#define SHADOW_PREFERTYPE	1
#endif

	// by default blending is enabled
#ifndef ALPHA_STANDARD
#define ALPHA_STANDARD		TRUE
#endif

	// extra technique for two-sided alpha
//#define ALPHA_TWOSIDED

	// standard technique draws depth pass first
#define LAYDEPTHFIRST

// misc other
	// Phong, otherwise Blinn is used
#define LIGHTING_PHONG
	// specular is not weighted but always 0 within shadow
#define SHADOW_REMSPEC

	// textures and colorpickers loaded/converted as SRGB and 
	// output gamma corrected
#define COLOR_SRGB

	// if COLOR_SRGB active
	// pow(2.2) otherwise accurate version
#define SRGB_SIMPLE

	// for colored gloss, otherwise better 
	// disable to mimmick "alpha" channel non SRGB
	// correction in texture maps
#define GLOSS_AFFECTEDBYSRGB

	// support for object space mirror via TS_CUSTOM
#define OS_MIRROR
	// support for custom tangentspace
#define TS_CUSTOM
	// normalize per-pixel tangentbasis
#define TS_NORMALIZE

	// sets anistropic filtering for non-cubemaps
#define TEX_ANISO		4
	// sets sampler lodbias for non-cubemaps
#define TEX_LODBIAS 	0


	// AmbientCubemap sampled for specularity as well
//#define AMBIENT_SPEC


/////////////////////////////////////////////////
// Shadows
#ifndef _3DSMAX_VERSION
	sampler2D g_ShadowSampler;
	#define SHADOW_FUNCTOR(name)	\
		float name(float4 wpos) { return tex2Dproj(g_ShadowSampler,wpos).x; }
#elif _3DSMAX_VERSION < 10000
	
	#define SHADOW_FUNCTOR(name)	\
		float name(float4 wpos) { return 1;}
	#define SHADOW_DISABLE
#else
	#include <shadowMap.fxh>
#endif

#if _3DSMAX_VERSION >= 12000 && SHADOW_PREFERTYPE == 3
	AREA_SHADOW_FUNCTOR(getShadowLight1,OMNI_LGT,true);
	AREA_SHADOW_FUNCTOR(getShadowLight2,OMNI_LGT,true);
#elif _3DSMAX_VERSION >= 12000 && SHADOW_PREFERTYPE == 2
	SOFT_SHADOW_FUNCTOR(getShadowLight1,OMNI_LGT,true);
	SOFT_SHADOW_FUNCTOR(getShadowLight2,OMNI_LGT,true);
#elif _3DSMAX_VERSION >= 11000
	SHADOW_FUNCTOR(getShadowLight1);
	SHADOW_FUNCTOR(getShadowLight2);
	#undef SHADOW_PREFERTYPE
	#define SHADOW_PREFERTYPE	1
#else
	SHADOW_FUNCTOR(getShadowLight2);
	SHADOW_FUNCTOR(getShadowLight1);
	#undef SHADOW_PREFERTYPE
	#define SHADOW_PREFERTYPE	1
#endif

#if SHADOW_PREFERTYPE > 1
	#define LIGHT_SCALE	0.225
#else
	#define LIGHT_SCALE	1.0
#endif

/////////////////////////////////////////////////
// Lights

#if defined(_3DSMAX_)
	#define LIGHTPOS	Position
#else
	#define LIGHTPOS	LightPos
#endif

bool g_UseLight1 <
	string UIName = "Use Light1";
> = true;

float4 g_wLightPos1 : LIGHTPOS 
<
	string UIName = "Light1";
    string Object = "OmniLight";
    string Space = "World";
    int RefID = 0;
> = {-54.0f, 50.0f, 100.0f, 1.0f};

float4 g_LightColor1 : LightColor <
	string UIWidget = "none";
	int LightRef = 0;
> = float4( 1.0f, 1.0f, 1.0f, 1.0f );

#ifndef SHADOW_DISABLE
float g_Light1ShadowBias
<
	string UIType = "FloatSpinner";
	float UIMin		= -1000;
	float UIMax		= 1000;
	float UIStep	= 0.1;
	string UIName	=  "Light1 ShadowBias";
> = 0.5;
#endif

bool g_UseLight2 <
	string UIName = "Use Light2";
> = false;

float4 g_wLightPos2 : LIGHTPOS 
<
	string UIName = "Light2";
    string Object = "OmniLight";
    string Space = "World";
    int RefID = 1;
> = {-54.0f, 50.0f, 100.0f, 1.0f};

float4 g_LightColor2 : LightColor <
	string UIWidget = "none";
	int LightRef = 1;
> = float4( 1.0f, 1.0f, 1.0f, 1.0f );


#ifndef SHADOW_DISABLE
float g_Light2ShadowBias
<
	string UIType = "FloatSpinner";
	float UIMin		= -1000;
	float UIMax		= 1000;
	float UIStep	= 0.1;
	string UIName	=  "Light2 ShadowBias";
> = 0.5;
#endif

bool g_UseLight3 <
	string UIName = "Use Light3";
> = false;

float4 g_wLightPos3 : LIGHTPOS 
<
	string UIName = "Light3";
    string Object = "OmniLight";
    string Space = "World";
    int RefID = 2;
> = {-54.0f, 50.0f, 100.0f, 1.0f};

float4 g_LightColor3 : LightColor <
	string UIWidget = "none";
	int LightRef = 2;
> = float4( 1.0f, 1.0f, 1.0f, 1.0f ); 

int g_UsedLights
<
	string UIType = "IntSpinner";
	float UIMin		= 0;
	float UIMax		= 3;
	float UIStep	= 1;
	string UIName	=  "Active Lights";
> = 1;

bool g_UseLightShadows <
	string UIName = "Use Shadows";
> = false;

float g_Light1DistanceDiv
<
	string UIType = "FloatSpinner";
	float UIMin		= 0.000000001;
	float UIMax		= 1;
	float UIStep	= 0.00001;
	string UIName	=  "Light1 1/Distance";
> = 0.000000001;

float g_Light2DistanceDiv
<
	string UIType = "FloatSpinner";
	float UIMin		= 0.000000001;
	float UIMax		= 1;
	float UIStep	= 0.00001;
	string UIName	=  "Light2 1/Distance";
> = 0.000000001;

float g_Light3DistanceDiv
<
	string UIType = "FloatSpinner";
	float UIMin		= 0.000000001;
	float UIMax		= 1;
	float UIStep	= 0.00001;
	string UIName	=  "Light3 1/Distance";
> = 0.000000001;


bool g_UseLightDef1 <
	string UIName = "Use Light1 Default Direction";
> = false;
bool g_UseLightDef2 <
	string UIName = "Use Light2 Default Direction";
> = false;
bool g_UseLightDef3 <
	string UIName = "Use Light3 Default Direction";
> = false;


/////////////////////////////////////////////////
// Main Functions

#ifdef COLOR_SRGB
#define USE_SRGB	SRGBTEXTURE = TRUE;
#else
#define USE_SRGB
#endif

#ifdef TEX_ANISO
#define TEX_FILTER	Anisotropic
#else
#define TEX_FILTER	Linear
#define TEX_ANISO	0
#endif

#ifndef TEX_LODBIAS
#define TEX_LODBIAS 0
#endif

// DIFFUSE
float4 g_DiffuseColor
<
	string type		= "color";
	string UIName	= "Diffuse Color";
	string UIWidget = "Color";
> = {0.32, 0.32, 0.32, 1.0};

texture g_DiffuseTexture	: DiffuseMap
< 
	string UIName = "DiffuseMap";
>;
sampler2D g_DiffuseSampler = sampler_state 
{	
	Texture = <g_DiffuseTexture>;
	USE_SRGB
	MinFilter	=	TEX_FILTER;
	MagFilter	=	Linear;
	MipFilter	=	Linear;
	AddressU	=	WRAP;
	AddressV	=	WRAP;
	MaxAnisotropy = TEX_ANISO;
	MipMapLodBias = TEX_LODBIAS;
};


bool g_UseDiffuseMap <
	string UIName = "Use DiffuseMap";
> = false;

float g_DiffuseStrength
<
	string UIType = "FloatSpinner";
	float UIMin		= -1000;
	float UIMax		= 1000;
	float UIStep	= 0.1;
	string UIName	=  "Diffuse Strength";
> = 1.0;


// SPECULAR
float4 g_SpecularColor
<
	string type		= "color";
	string UIName	= "Specular Color";
	string UIWidget = "Color";
> = {1.0, 1.0, 1.0, 1.0};

texture g_SpecularTexture	: SpecularMap
<
	string UIName = "SpecularMap";
>;
sampler2D g_SpecularSampler = sampler_state
{
	Texture = <g_SpecularTexture>;
	USE_SRGB
	MinFilter	=	TEX_FILTER;
	MagFilter	=	Linear;
	MipFilter	=	Linear;
	AddressU	=	WRAP;
	AddressV	=	WRAP;
	MaxAnisotropy = TEX_ANISO;
	MipMapLodBias = TEX_LODBIAS;
};

bool g_UseSpecularMap <
	string UIName = "Use SpecularMap";
> = false;

float g_SpecularStrength
<
	string UIType = "FloatSpinner";
	float UIMin		= -1000;
	float UIMax		= 1000;
	float UIStep	= 0.1;
	string UIName	=  "Specular Strength";
> = 1.0;

float4 g_GlossColor
<
	string type		= "color";
	string UIName	= "Gloss Color";
	string UIWidget = "Color";
> = {1.0, 1.0, 1.0, 1.0};

// GLOSS 
texture g_GlossTexture	: GlossMap
<
	string UIName = "GlossMap";
>;
sampler2D g_GlossSampler = sampler_state
{
	Texture = <g_GlossTexture>;
#ifdef GLOSS_AFFECTEDBYSRGB
	USE_SRGB
#endif
	MinFilter	=	TEX_FILTER;
	MagFilter	=	Linear;
	MipFilter	=	Linear;
	AddressU	=	WRAP;
	AddressV	=	WRAP;
	MaxAnisotropy = TEX_ANISO;
	MipMapLodBias = TEX_LODBIAS;
};

bool g_UseGlossMap <
	string UIName = "Use GlossMap";
> = false;

float g_GlossStrength
<
	string UIType = "FloatSpinner";
	float UIMin		= -1000;
	float UIMax		= 1000;
	float UIStep	= 0.1;
	string UIName	=  "Gloss Strength";
> = 25.0;


// NORMAL
texture g_NormalTexture : NormalMap
< 
	string UIName = "NormalMap";
>;
sampler2D g_NormalSampler = sampler_state
{
	Texture = <g_NormalTexture>;
	MinFilter	=	TEX_FILTER;
	MagFilter	=	Linear;
	MipFilter	=	Linear;
	AddressU	=	WRAP;
	AddressV	=	WRAP;
	MaxAnisotropy = TEX_ANISO;
	MipMapLodBias = TEX_LODBIAS;
};

bool g_UseNormalMap <
	string UIName = "Use NormalMap";
> = false;

float g_NormalStrength
<
	string UIType = "FloatSpinner";
	float UIMin		= -1000;
	float UIMax		= 1000;
	float UIStep	= 0.1;
	string UIName	=  "Normal Strength";
> = 1.0;

bool g_UseNormalOS <
	string UIName = "Use Object-Space Normals";
> = false;

#ifdef TS_CUSTOM
bool g_UseNormalCTS <
	string UIName = "Use Quality Normals (requires modifier)";
> = false;
#endif

// EMISSIVE
float4 g_EmissiveColor
<
	string type		= "color";
	string UIName	= "Glow Color";
	string UIWidget = "Color";
> = {0.0, 0.0, 0.0, 0.0};

texture g_EmissiveTexture: LightMap
< 
	string UIName = "GlowMap";
>;
sampler2D g_EmissiveSampler = sampler_state 
{	
	Texture = <g_EmissiveTexture>;
	USE_SRGB
	MinFilter	=	TEX_FILTER;
	MagFilter	=	Linear;
	MipFilter	=	Linear;
	AddressU	=	WRAP;
	AddressV	=	WRAP;
	MaxAnisotropy = TEX_ANISO;
	MipMapLodBias = TEX_LODBIAS;
};

bool g_UseEmissiveMap <
	string UIName = "Use GlowMap";
> = false;

float g_EmissiveStrength
<
	string UIType = "FloatSpinner";
	float UIMin		= -1000;
	float UIMax		= 1000;
	float UIStep	= 0.1;
	string UIName	=  "Glow Strength";
> = 1.0;




// ALPHA
bool g_UseAlpha <
	string UIName = "Use Opacity from DiffuseMap.Alpha";
> = false;

float g_AlphaStrength
<
	string UIType = "FloatSpinner";
	float UIMin		= -1000;
	float UIMax		= 1000;
	float UIStep	= 0.1;
	string UIName	=  "Opacity Strength";
> = 1.0;

// OCCLUSION
texture g_OcclusionTexture
<
	string UIName = "Occlusion Mask";
>;
sampler2D g_OcclusionSampler = sampler_state
{
	Texture = <g_OcclusionTexture>;
	USE_SRGB
	MinFilter	=	TEX_FILTER;
	MagFilter	=	Linear;
	MipFilter	=	Linear;
	AddressU	=	WRAP;
	AddressV	=	WRAP;
	MaxAnisotropy = TEX_ANISO;
	MipMapLodBias = TEX_LODBIAS;
};

bool g_UseOcclusionAmbient <
	string UIName = "Use Ambient Occlusion(RGB)";
> = false;
bool g_UseOcclusionReflection <
	string UIName = "Use Reflection Occlusion(Alpha)";
> = false;

float g_OcclusionStrength
<
	string UIType = "FloatSpinner";
	float UIMin		= 0;
	float UIMax		= 1;
	float UIStep	= 0.1;
	string UIName	=  "Ambient Occ. Strength";
> = 1.0;

float g_OcclusionStrength2
<
	string UIType = "FloatSpinner";
	float UIMin		= 0;
	float UIMax		= 1;
	float UIStep	= 0.1;
	string UIName	=  "Reflection Occ. Strength";
> = 1.0;

// AMBIENT

texture g_AmbientTexture
<
	string UIName = "AmbientCube";
	string ResourceType = "CUBE";
>;
samplerCUBE g_AmbientSampler = sampler_state
{
	Texture = <g_AmbientTexture>;
	USE_SRGB
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU = CLAMP;
	AddressV = CLAMP;
	AddressW = CLAMP;
};

bool g_UseAmbientMap <
	string UIName = "Use AmbientCube";
> = false;

float g_AmbientStrength
<
	string UIType = "FloatSpinner";
	float UIMin		= -1000;
	float UIMax		= 1000;
	float UIStep	= 0.01;
	string UIName	=  "AmbientCube Strength";
> = 1.0;

float g_AmbientContrast
<
	string UIType = "FloatSpinner";
	float UIMin		= 0.0001;
	float UIMax		= 1000;
	float UIStep	= 0.01;
	string UIName	=  "AmbientCube Gamma";
> = 1.0;

float g_AmbientBlur
<
	string UIType = "FloatSpinner";
	float UIMin		= 0;
	float UIMax		= 32;
	float UIStep	= 0.1;
	string UIName	=  "AmbientCube Blur";
> = 0.0;


// REFLECTION
texture g_ReflectionTexture
<
	string UIName = "ReflectionCube";
	string ResourceType = "CUBE";
>;
samplerCUBE g_ReflectionSampler = sampler_state
{
	Texture = <g_ReflectionTexture>;
	USE_SRGB
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU = CLAMP;
	AddressV = CLAMP;
	AddressW = CLAMP;
};

bool g_UseReflectionMap <
	string UIName = "Use ReflectionCube";
> = false;

float g_ReflectionStrength
<
	string UIType = "FloatSpinner";
	float UIMin		= -1000;
	float UIMax		= 1000;
	float UIStep	= 0.01;
	string UIName	=  "ReflectionCube Strength";
> = 1.0;

float g_ReflectionContrast
<
	string UIType = "FloatSpinner";
	float UIMin		= 0.0001;
	float UIMax		= 1000;
	float UIStep	= 0.01;
	string UIName	=  "ReflectionCube Gamma";
> = 1.0;

float g_ReflectionBlur
<
	string UIType = "FloatSpinner";
	float UIMin		= 0;
	float UIMax		= 32;
	float UIStep	= 0.1;
	string UIName	=  "ReflectionCube Blur";
> = 0.0;


/////////////////////////////////////////////////
// Additional Params

// DIFFUSE
bool g_UseDiffuseFresnel <
	string UIName = "Use DiffuseFresnel";
> = false;

float4 g_DiffuseFTintColor
<
	string type		= "color";
	string UIName	= "DiffuseFresnel Color";
	string UIWidget = "Color";
> = {1.0, 0.5, 0.0, 1.0};

float g_DiffuseFStrength
<
	string UIType = "FloatSpinner";
	float UIMin		= -1000;
	float UIMax		= 1000;
	float UIStep	= 0.1;
	string UIName	=  "DiffuseFresnel Strength";
> = 2.0;

float g_DiffuseFPower
<
	string UIType = "FloatSpinner";
	float UIMin		= -1000;
	float UIMax		= 1000;
	float UIStep	= 0.1;
	string UIName	=  "DiffuseFresnel Power";
> = 4.0;

float g_DiffuseFBias
<
	string UIType = "FloatSpinner";
	float UIMin		= -1000;
	float UIMax		= 1000;
	float UIStep	= 0.1;
	string UIName	=  "DiffuseFresnel Bias";
> = 0.0;


// SPECULAR 

bool g_UseSpecularAdd <
	string UIName = "Use Additive Specular";
> = true;

bool g_UseSpecularRefDecal <
	string UIName = "Use Decal Reflection";
> = false;

bool g_UseSpecularOpacity <
	string UIName = "Use Opacity Specular";
> = false;

float g_SpecularRefFPower
<
	string UIType = "FloatSpinner";
	float UIMin		= -1000;
	float UIMax		= 1000;
	float UIStep	= 0.1;
	string UIName	=  "RefFresnel Power";
> = 1.0;

float g_SpecularRefFBias
<
	string UIType = "FloatSpinner";
	float UIMin		= -1000;
	float UIMax		= 1000;
	float UIStep	= 0.1;
	string UIName	=  "RefFresnel Bias";
> = 0.0;


// GLOSS
float g_GlossRefBlur
<
	string UIType = "FloatSpinner";
	float UIMin		= 0;
	float UIMax		= 32;
	float UIStep	= 0.1;
	string UIName	=  "Gloss RefBlur";
> = 5.0;

float g_GlossRefBias
<
	string UIType = "FloatSpinner";
	float UIMin		= -1000;
	float UIMax		= 1000;
	float UIStep	= 0.01;
	string UIName	=  "Gloss RefBlur Value";
> = 0.5;

float g_GlossRefContrast
<
	string UIType = "FloatSpinner";
	float UIMin		= -1000;
	float UIMax		= 1000;
	float UIStep	= 0.01;
	string UIName	=  "Gloss RefBlur Contrast";
> = 1.0;

// GLOW
int g_EmissiveMode <
	string UIType = "IntSpinner";
	float UIMin		= 1;
	float UIMax		= 3;
	float UIStep	= 1;
	string UIName	=  "Glow Mode (add,mod,max)";
> = 1;

// ALPHA
float g_AlphaStrength2
<
	string UIType = "FloatSpinner";
	float UIMin		= -1000;
	float UIMax		= 1000;
	float UIStep	= 0.1;
	string UIName	=  "Light Opacity Influence";
> = 0.0;


bool g_UseAlphaTest <
	string UIName = "Use Opacity Alpha Test";
> = false;

bool g_UseAlphaFresnel <
	string UIName = "Use Opacity Fresnel";
> = false;

float g_AlphaFStrength
<
	string UIType = "FloatSpinner";
	float UIMin		= -1000;
	float UIMax		= 1000;
	float UIStep	= 0.1;
	string UIName	=  "OpacityFresnel Strength";
> = 4.0;

float g_AlphaFPower
<
	string UIType = "FloatSpinner";
	float UIMin		= -1000;
	float UIMax		= 1000;
	float UIStep	= 0.1;
	string UIName	=  "OpacityFresnel Power";
> = 4.0;

float g_AlphaFBias
<
	string UIType = "FloatSpinner";
	float UIMin		= -1000;
	float UIMax		= 1000;
	float UIStep	= 0.1;
	string UIName	=  "OpacityFresnel Bias";
> = 0.0;

#ifdef ALPHA_TWOSIDED
bool g_UseTwosidedFlip <
	string UIName = "Use TwosidedFlip";
> = false;
#endif

// NORMAL
bool g_UseNormalFlipX <
	string UIName = "Flip NormalMap X";
> = false;

bool g_UseNormalFlipY <
	string UIName = "Flip NormalMap Y";
> = true;

// UV
bool g_UseEmissive2ndUV <
	string UIName = "Use Glow 2ndUV";
> = false;

bool g_UseOcclusionAmbient2ndUV <
	string UIName = "Use AmbiOcc 2ndUV";
> = false;
bool g_UseOcclusionReflection2ndUV <
	string UIName = "Use RefOcc 2ndUV";
> = false;

// AMBIENT

#ifdef AMBIENT_SPEC
float g_AmbientSpecBias
<
	string UIType = "FloatSpinner";
	float UIMin		= -1000;
	float UIMax		= 1000;
	float UIStep	= 0.1;
	string UIName	=  "AmbSpecular Bias";
> = 0.0;

float g_AmbientSpecular
<
	string UIType = "FloatSpinner";
	float UIMin		= -1000;
	float UIMax		= 1000;
	float UIStep	= 0.1;
	string UIName	=  "AmbSpecular";
> = 1.0;

float g_AmbientSpecBlur
<
	string UIType = "FloatSpinner";
	float UIMin		= 0;
	float UIMax		= 20;
	float UIStep	= 0.1;
	string UIName	=  "AmbSpecular Blur";
> = 0.0;
#endif



/////////////////////////////////////////////////
// Special

float4 g_EnvCubeRot
<
	string type		= "color";
	string UIName	= "CubeRotation (cos,sin,-sin,0)";
	string UIWidget = "Color";
> = {1.0, 0.0, 0.0, 0.0};


/////////////////////////////////////////////////
// SHADER CODE

#define SQUARE(X) 		((X)*(X))

/////////////////////////////////////////////////
// Matrices
float4x4 WorldViewProj	: WORLDVIEWPROJECTION;
float4x4 World			: WORLD;
float4x4 WorldInvTrans  : WORLDINVERSETRANSPOSE;
float4x4 ViewInv		: VIEWINVERSE;


/////////////////////////////////////////////////
// Texture Coords
#if defined(_3DSMAX_)
int texcoord0 : Texcoord
<
	string UIWidget = "none";
	int Texcoord = 0;
	int MapChannel = 1;
>;

int texcoord1 : Texcoord
<
	string UIWidget = "none";
	int Texcoord = 1;
	int MapChannel = 2;
>;


#if defined(OS_MIRROR) || defined(TS_CUSTOM)
int tstangent : Texcoord
<
	string UIWidget = "none";
	int Texcoord = 2;
	int MapChannel = 3;
>;
#endif

#if defined(TS_CUSTOM)
int tsbinormal : Texcoord
<
	string UIWidget = "none";
	int Texcoord = 3;
	int MapChannel = 4;
>;
int tsnormal : Texcoord
<
	string UIWidget = "none";
	int Texcoord = 4;
	int MapChannel = 5;
>;
#endif
#endif



/////////////////////////////////////////////////
// Comm 

struct APP_INPUT
{
	float4 oPosition : POSITION;
	float4 Texcoord0  : TEXCOORD0;
	float4 Texcoord1	: TEXCOORD1;
	
#ifdef TS_CUSTOM
	float3 oTangent1	: TEXCOORD2;
	float3 oBinormal1: TEXCOORD3;
	float3 oNormal1	: TEXCOORD4;
#elif defined (OS_MIRROR)
	float3 oTangent1	: TEXCOORD2;
#endif
	float3 oNormal 	: NORMAL;
	float3 oTangent  : TANGENT;
	float3 oBinormal : BINORMAL;
};

struct vOUT_MAIN
{
	float4 hPosition		: POSITION;

	float4 Texcoord01	: TEXCOORD0;
	float3 wPos			: TEXCOORD1;
	float3 wTangent		: TEXCOORD2; // or oMirror
	float3 wBinormal 	: TEXCOORD3;
	float3 wNormal 		: TEXCOORD4;
	float3 wDefaultLight: TEXCOORD5;
};

struct vOUT_DEPTH
{
	float4 hPosition		: POSITION;
	float2 Texcoord0	: TEXCOORD0;
};



/////////////////////////////////////////////////
// Depth Only Pass

vOUT_DEPTH Main_Depth_VS11(APP_INPUT IN)
{
	vOUT_DEPTH OUT;
	OUT.hPosition	= mul(IN.oPosition,WorldViewProj);
	OUT.Texcoord0   = IN.Texcoord0.xy;
	return OUT;
}

float4 LayDepth(vOUT_DEPTH IN) : COLOR
{
	float4 diffuse = g_UseAlpha 	? tex2D(g_DiffuseSampler,IN.Texcoord0) 	: (float4)1;
	
	if (g_UseAlphaTest){
		clip(diffuse.w-g_AlphaStrength);
	}
	return 1;
}

/////////////////////////////////////////////////
// Vertex shader

vOUT_MAIN Main_3Light_VS11(APP_INPUT IN)
{
	vOUT_MAIN OUT;
	float3 tangent  = IN.oTangent.xyz;
	float3 normal   = IN.oNormal.xyz;
	float3 binormal = IN.oBinormal.xyz;

	// position ,uvs
	OUT.hPosition	= mul(IN.oPosition,WorldViewProj);
	OUT.Texcoord01  = float4(IN.Texcoord0.xy, IN.Texcoord1.xy);
	
	float3 wPos = mul(IN.oPosition,World).xyz;
	OUT.wPos = wPos;
	
	if (g_UseNormalMap && !g_UseNormalOS){
	#ifdef TS_CUSTOM
		if (g_UseNormalCTS){
			tangent  = IN.oBinormal1.xyz;
			normal   = IN.oNormal1.xyz;
			binormal = IN.oTangent1.xyz;
			normal.y *=-1;
			tangent.x *= -1;
			tangent.z *= -1;
			binormal.y *= -1;	
		}
	#endif
		OUT.wBinormal =  mul(binormal,(float3x3)WorldInvTrans);
		OUT.wTangent  =  -mul(tangent, (float3x3)WorldInvTrans);
		
		if (g_UseNormalFlipY){
			OUT.wTangent = -OUT.wTangent;
		}
		if (g_UseNormalFlipX){
			OUT.wBinormal = -OUT.wBinormal;
		}
	}
	else{
		OUT.wTangent = OUT.wBinormal = 0;
		#ifdef OS_MIRROR
		if (g_UseNormalCTS){
			OUT.wTangent = IN.oTangent1;
		}
		#endif
		
	}
	OUT.wNormal = mul(normal,(float3x3)WorldInvTrans);
	
	OUT.wDefaultLight = normalize(mul(float3(0.5,0.7,-1),(float3x3)ViewInv));
	
	return OUT;
}


// PRECOMPILED BARRIER
///////////////////////////////////////////////////////////////
//=============================================================
///////////////////////////////////////////////////////////////
#ifndef PRECOMPILED


#else
// PRECOMPILED BARRIER
///////////////////////////////////////////////////////////////
//=============================================================
///////////////////////////////////////////////////////////////

struct _vOUT_MAIN {
    float4 _Texcoord01 : TEXCOORD0;
    float3 _wPos1 : TEXCOORD1;
    float3 _wTangent : TEXCOORD2;
    float3 _wBinormal : TEXCOORD3;
    float3 _wNormal : TEXCOORD4;
    float3 _wDefaultLight : TEXCOORD5;
};


struct PixelInfo {
    float4 _emissive;
    float4 _diffuse4;
    float4 _gloss;
    float4 _specular3;
    float4 _refl;
    float _refblur;
    float _opacity;
};

struct LightInfo {
    float4 _color7;
    float3 _wLightDir1;
    float _wLightDist;
    float2 _LdotNR;
};

struct EnvInfo {
    float3 _wPos2;
    float3 _wNormal1;
    float3 _wEyeDir;
    float3 _wReflect;
    float3 _wDefaultLightDir;
    float _OneMinusNdotE;
};

 // main procedure, the original name was Main_Standard_PS3
float4 Main_Standard_PS3(in _vOUT_MAIN _IN1, uniform bool shadows, uniform bool invnormal ) : COLOR0
{
	float3 _TMP50022;
	float4 _rocc10022;
	float2 _tcocc20022;
	float2 _tcocc10022;
	PixelInfo _pix0022;
	float4 _color0024;
	float4 _color0026;
	float3 _TMP27;
	float4 _color0032;
	float4 _color0034;
	float3 _TMP35;
	float4 _color0040;
	float4 _color0042;
	float3 _TMP43;
	float4 _color0048;
	float4 _color0050;
	float3 _TMP51;
	float4 _c0058;
	float4 _ctr0058;
	float _c0059;
	float4 _b0063;
	float4 _b0065;
	float _NdotE0067;
	float3 _normal10067;
	EnvInfo _env0067;
	float3 _TMP68;
	float3 _v0069;
	float3 _r0071;
	float3 _TMP72;
	float3 _TMP74;
	float3 _TMP76;
	float3 _TMP78;
	float _falloff0081;
	float3 _wLightDir0081;
	LightInfo _linf0081;
	float4 _color0081;
	float _TMP82;
	float _a0083;
	float _falloff0085;
	float3 _wLightDir0085;
	LightInfo _linf0085;
	float4 _color0085;
	float _TMP86;
	float _a0087;
	float _falloff0089;
	float3 _wLightDir0089;
	LightInfo _linf0089;
	float4 _color0089;
	float _TMP90;
	float _a0091;
	LightInfo _linfos0092[3];
	float _TMP93;
	float4 _wpos0094;
	float _TMP97;
	float4 _wpos0098;
	float _transp0102;
	float _diffcontrib0102;
	float _speccontrib0102;
	float4 _outcolor0102;
	float4 _diffusecolor0102;
	float4 _specular0102;
	float4 _diffuse0103;
	float3x3 _TMP150105;
	float3 _r0109;
	float4 _TMP110;
	float4 _a0111;
	LightInfo _linf10112;
	int _i10112;
	float4 _diffuse0112;
	float4 _specular0112;
	float4 _TMP114;
	float _TMP116;
	float _a0121;
	float4 _factor10122;
	float4 _cubemap10122;
	float4 _color0122;
	float4 _light0122;
	float3x3 _TMP150124;
	float3 _r0128;
	float4 _TMP129;
	float4 _t0132;
	float3 _a0138;
	float _t0138;
	float4 _clr10139;
	float4 _factor10139;
	float4 _strength10139;
	float4 _bias10139;
	float4 _power10139;
	float4 _color0139;
	float _diffalpha0139;
	float4 _TMP140;
	float4 _color0143;
	float4 _t0145;
	float4 _color0147;
	float3 _TMP148;
	float4 _color0153;
	float3 _TMP156;
	float3 _a0157;



    LightInfo _linfos3[3];

    _color0024 = g_EmissiveColor;
    _TMP27 = float3(pow(g_EmissiveColor.x,  2.20000004768371580E000f), pow(g_EmissiveColor.y,  2.20000004768371580E000f), pow(g_EmissiveColor.z,  2.20000004768371580E000f));
    _color0026.xyz = _TMP27*(float3) (g_EmissiveColor.xyz >= float3(  9.99999974737875160E-005f,  9.99999974737875160E-005f,  9.99999974737875160E-005f));
    _color0024.xyz = _color0026.xyz;
    _pix0022._emissive = g_UseEmissiveMap ? tex2D(g_EmissiveSampler, g_UseEmissive2ndUV ? _IN1._Texcoord01.zw : _IN1._Texcoord01.xy) : _color0024;
    _color0032 = g_DiffuseColor;
    _TMP35 = float3(pow(g_DiffuseColor.x,  2.20000004768371580E000f), pow(g_DiffuseColor.y,  2.20000004768371580E000f), pow(g_DiffuseColor.z,  2.20000004768371580E000f));
    _color0034.xyz = _TMP35*(float3) (g_DiffuseColor.xyz >= float3(  9.99999974737875160E-005f,  9.99999974737875160E-005f,  9.99999974737875160E-005f));
    _color0032.xyz = _color0034.xyz;
    _pix0022._diffuse4 = g_UseDiffuseMap ? tex2D(g_DiffuseSampler, _IN1._Texcoord01.xy) : _color0032;
    _pix0022._diffuse4.w = g_UseAlpha ? tex2D(g_DiffuseSampler, _IN1._Texcoord01.xy).w :  1.00000000000000000E000f;
    _color0040 = g_GlossColor;
    _TMP43 = float3(pow(g_GlossColor.x,  2.20000004768371580E000f), pow(g_GlossColor.y,  2.20000004768371580E000f), pow(g_GlossColor.z,  2.20000004768371580E000f));
    _color0042.xyz = _TMP43*(float3) (g_GlossColor.xyz >= float3(  9.99999974737875160E-005f,  9.99999974737875160E-005f,  9.99999974737875160E-005f));
    _color0040.xyz = _color0042.xyz;
    _pix0022._gloss = g_UseGlossMap ? tex2D(g_GlossSampler, _IN1._Texcoord01.xy) : _color0040;
    _color0048 = g_SpecularColor;
    _TMP51 = float3(pow(g_SpecularColor.x,  2.20000004768371580E000f), pow(g_SpecularColor.y,  2.20000004768371580E000f), pow(g_SpecularColor.z,  2.20000004768371580E000f));
    _color0050.xyz = _TMP51*(float3) (g_SpecularColor.xyz >= float3(  9.99999974737875160E-005f,  9.99999974737875160E-005f,  9.99999974737875160E-005f));
    _color0048.xyz = _color0050.xyz;
    _pix0022._specular3 = g_UseSpecularMap ? tex2D(g_SpecularSampler, _IN1._Texcoord01.xy) : _color0048;
    _c0058 = dot(float3(  3.00000011920928960E-001f,  5.89999973773956300E-001f,  1.09999999403953550E-001f), _pix0022._gloss.xyz).xxxx;
    _ctr0058 = (g_GlossRefContrast +  1.00000000000000000E000f).xxxx;
    _pix0022._refblur = saturate(((_c0058 -  5.00000000000000000E-001f)*_ctr0058 +  5.00000000000000000E-001f).x + g_GlossRefBias);
    _pix0022._refblur = ( 1.00000000000000000E000f - _pix0022._refblur)*g_GlossRefBlur;
    _pix0022._emissive = _pix0022._emissive*g_EmissiveStrength.xxxx;
    _pix0022._specular3 = _pix0022._specular3*g_SpecularStrength.xxxx;
    _pix0022._refl = g_ReflectionStrength.xxxx;
    if (g_UseAlphaTest) { // if begin
        _c0059 = _pix0022._diffuse4.w - g_AlphaStrength;
        if (_c0059 <  0.00000000000000000E000f) { // if begin
            clip(-1.0f);
        } // end if
        _pix0022._opacity =  1.00000000000000000E000f;
    } else {
        _pix0022._opacity = g_AlphaStrength;
    } // end if
    _pix0022._diffuse4 = _pix0022._diffuse4*float4(g_DiffuseStrength.x, g_DiffuseStrength.x, g_DiffuseStrength.x,  1.00000000000000000E000f);
    _pix0022._gloss = float4(  1.00000000000000000E000f,  1.00000000000000000E000f,  1.00000000000000000E000f,  1.00000000000000000E000f) + _pix0022._gloss*(g_GlossStrength.xxxx - float4(  1.00000000000000000E000f,  1.00000000000000000E000f,  1.00000000000000000E000f,  1.00000000000000000E000f));
    if (g_UseOcclusionAmbient) { // if begin
        _tcocc10022 = g_UseOcclusionAmbient2ndUV ? _IN1._Texcoord01.zw : _IN1._Texcoord01.xy;
        _TMP50022 = tex2D(g_OcclusionSampler, _tcocc10022).xyz;
        _b0063 = float4(_TMP50022.x, _TMP50022.y, _TMP50022.z,  1.00000000000000000E000f);
        _pix0022._diffuse4 = _pix0022._diffuse4*(float4(  1.00000000000000000E000f,  1.00000000000000000E000f,  1.00000000000000000E000f,  1.00000000000000000E000f) + g_OcclusionStrength*(_b0063 - float4(  1.00000000000000000E000f,  1.00000000000000000E000f,  1.00000000000000000E000f,  1.00000000000000000E000f)));
    } // end if
    if (g_UseOcclusionReflection) { // if begin
        _tcocc20022 = g_UseOcclusionReflection2ndUV ? _IN1._Texcoord01.zw : _IN1._Texcoord01.xy;
        _b0065 = tex2D(g_OcclusionSampler, _tcocc20022).wwww;
        _rocc10022 = float4(  1.00000000000000000E000f,  1.00000000000000000E000f,  1.00000000000000000E000f,  1.00000000000000000E000f) + g_OcclusionStrength2*(_b0065 - float4(  1.00000000000000000E000f,  1.00000000000000000E000f,  1.00000000000000000E000f,  1.00000000000000000E000f));
        _pix0022._refl = g_ReflectionStrength.xxxx*_rocc10022;
    } // end if
    _v0069 = ViewInv._41_42_43 - _IN1._wPos1;
    _TMP68 = rsqrt(dot(_v0069, _v0069))*_v0069;
    if (g_UseNormalMap) { // if begin
        _normal10067 = (tex2D(g_NormalSampler, _IN1._Texcoord01.xy).xyz* 2.55000000000000000E002f)/ 1.28000000000000000E002f -  1.00000000000000000E000f;
        if (g_UseNormalOS) { // if begin
            if (g_UseNormalFlipY) { // if begin
                _normal10067.y = -_normal10067.y;
            } // end if
            if (g_UseNormalFlipX) { // if begin
                _normal10067.x = -_normal10067.x;
            } // end if
            if (g_UseNormalCTS) { // if begin
                _normal10067 = _normal10067 - _IN1._wTangent*(dot(_IN1._wTangent, _normal10067)* 2.00000000000000000E000f);
            } // end if
            _r0071 = _normal10067.x*World._11_12_13;
            _r0071 = _r0071 + _normal10067.y*World._21_22_23;
            _r0071 = _r0071 + _normal10067.z*World._31_32_33;
            _env0067._wNormal1 = _r0071.xyz;
        } else {
            _normal10067.xy = _normal10067.xy*g_NormalStrength.xx;
            _TMP72 = rsqrt(dot(_IN1._wBinormal, _IN1._wBinormal))*_IN1._wBinormal;
            _env0067._wNormal1 = _normal10067.x*_TMP72;
            _TMP74 = rsqrt(dot(_IN1._wTangent, _IN1._wTangent))*_IN1._wTangent;
            _env0067._wNormal1 = _env0067._wNormal1 + _normal10067.y*_TMP74;
            _TMP76 = rsqrt(dot(_IN1._wNormal, _IN1._wNormal))*_IN1._wNormal;
            _env0067._wNormal1 = _env0067._wNormal1 + _normal10067.z*_TMP76;
        } // end if
    } else {
        _env0067._wNormal1 = _IN1._wNormal;
    } // end if
    _TMP78 = rsqrt(dot(_env0067._wNormal1, _env0067._wNormal1))*_env0067._wNormal1;
    _NdotE0067 = dot(_TMP78, _TMP68);
    _env0067._OneMinusNdotE =  1.00100004673004150E000f - saturate(_NdotE0067);
    _env0067._wReflect = ( 2.00000000000000000E000f*_NdotE0067)*_TMP78 - _TMP68;
    _color0081 = g_LightColor1;
    _wLightDir0081 = g_wLightPos1.xyz - _IN1._wPos1;
    _a0083 = dot(_wLightDir0081, _wLightDir0081);
    _TMP82 =  1.00000000000000000E000f/rsqrt(_a0083);
    _linf0081._wLightDist = _TMP82;
    _linf0081._wLightDir1 = _wLightDir0081/_TMP82;
    if (g_UseLightDef1) { // if begin
        _linf0081._wLightDir1 = _IN1._wDefaultLight;
        _linf0081._wLightDist =  0.00000000000000000E000f;
        _color0081 = float4(  1.00000000000000000E000f,  1.00000000000000000E000f,  1.00000000000000000E000f,  1.00000000000000000E000f);
    } // end if
    _linf0081._color7 = g_UseLight1 ? _color0081 : float4(  0.00000000000000000E000f,  0.00000000000000000E000f,  0.00000000000000000E000f,  0.00000000000000000E000f);
    _linf0081._LdotNR = float2(dot(_linf0081._wLightDir1, _TMP78), dot(_linf0081._wLightDir1, _env0067._wReflect));
    _linf0081._LdotNR = saturate(_linf0081._LdotNR);
    _falloff0081 = saturate(_linf0081._wLightDist*g_Light1DistanceDiv);
    _linf0081._color7 = _linf0081._color7*( 1.00000000000000000E000f - _falloff0081*_falloff0081).xxxx;
    _linf0081._color7.w =  0.00000000000000000E000f;
    _linfos3[0]._color7 = _linf0081._color7;
    _linfos3[0]._LdotNR = _linf0081._LdotNR;
    _color0085 = g_LightColor2;
    _wLightDir0085 = g_wLightPos2.xyz - _IN1._wPos1;
    _a0087 = dot(_wLightDir0085, _wLightDir0085);
    _TMP86 =  1.00000000000000000E000f/rsqrt(_a0087);
    _linf0085._wLightDist = _TMP86;
    _linf0085._wLightDir1 = _wLightDir0085/_TMP86;
    if (g_UseLightDef2) { // if begin
        _linf0085._wLightDir1 = _IN1._wDefaultLight;
        _linf0085._wLightDist =  0.00000000000000000E000f;
        _color0085 = float4(  1.00000000000000000E000f,  1.00000000000000000E000f,  1.00000000000000000E000f,  1.00000000000000000E000f);
    } // end if
    _linf0085._color7 = g_UseLight2 ? _color0085 : float4(  0.00000000000000000E000f,  0.00000000000000000E000f,  0.00000000000000000E000f,  0.00000000000000000E000f);
    _linf0085._LdotNR = float2(dot(_linf0085._wLightDir1, _TMP78), dot(_linf0085._wLightDir1, _env0067._wReflect));
    _linf0085._LdotNR = saturate(_linf0085._LdotNR);
    _falloff0085 = saturate(_linf0085._wLightDist*g_Light2DistanceDiv);
    _linf0085._color7 = _linf0085._color7*( 1.00000000000000000E000f - _falloff0085*_falloff0085).xxxx;
    _linf0085._color7.w =  0.00000000000000000E000f;
    _linfos3[1]._color7 = _linf0085._color7;
    _linfos3[1]._LdotNR = _linf0085._LdotNR;
    _color0089 = g_LightColor3;
    _wLightDir0089 = g_wLightPos3.xyz - _IN1._wPos1;
    _a0091 = dot(_wLightDir0089, _wLightDir0089);
    _TMP90 =  1.00000000000000000E000f/rsqrt(_a0091);
    _linf0089._wLightDist = _TMP90;
    _linf0089._wLightDir1 = _wLightDir0089/_TMP90;
    if (g_UseLightDef3) { // if begin
        _linf0089._wLightDir1 = _IN1._wDefaultLight;
        _linf0089._wLightDist =  0.00000000000000000E000f;
        _color0089 = float4(  1.00000000000000000E000f,  1.00000000000000000E000f,  1.00000000000000000E000f,  1.00000000000000000E000f);
    } // end if
    _linf0089._color7 = g_UseLight3 ? _color0089 : float4(  0.00000000000000000E000f,  0.00000000000000000E000f,  0.00000000000000000E000f,  0.00000000000000000E000f);
    _linf0089._LdotNR = float2(dot(_linf0089._wLightDir1, _TMP78), dot(_linf0089._wLightDir1, _env0067._wReflect));
    _linf0089._LdotNR = saturate(_linf0089._LdotNR);
    _falloff0089 = saturate(_linf0089._wLightDist*g_Light3DistanceDiv);
    _linf0089._color7 = _linf0089._color7*( 1.00000000000000000E000f - _falloff0089*_falloff0089).xxxx;
    _linf0089._color7.w =  0.00000000000000000E000f;
    _linfos3[2]._color7 = _linf0089._color7;
    _linfos3[2]._LdotNR = _linf0089._LdotNR;
    
#ifndef SHADOW_DISABLE
	if (shadows && g_UseLightShadows) { // if begin
        _wpos0094 = float4(_IN1._wPos1.x, _IN1._wPos1.y, _IN1._wPos1.z,  1.00000000000000000E000f);
        _TMP93 = saturate(getShadowLight1(_wpos0094));
		_a0121 = abs(g_Light1ShadowBias);
		_linf0081._color7.w = (float)(_a0121 > 0.0);
        _linfos0092[0]._color7 = _linf0081._color7*(g_UseLightDef1 ? float4(  1.00000000000000000E000f,  1.00000000000000000E000f,  1.00000000000000000E000f,  1.00000000000000000E000f) : ( 1.00000000000000000E000f + g_Light1ShadowBias*(_TMP93 -  1.00000000000000000E000f)).xxxx);
		_linfos0092[0]._color7.w = (abs(_linfos0092[0]._color7.w - 1) / (_a0121 + 0.0000001));
        _wpos0098 = float4(_IN1._wPos1.x, _IN1._wPos1.y, _IN1._wPos1.z,  1.00000000000000000E000f);
        _TMP97 = saturate(getShadowLight2(_wpos0094));
		_a0121 = abs(g_Light2ShadowBias);
		_linf0085._color7.w = (float)(_a0121 > 0.0);
        _linfos0092[1]._color7 = _linf0085._color7*(g_UseLightDef2 ? float4(  1.00000000000000000E000f,  1.00000000000000000E000f,  1.00000000000000000E000f,  1.00000000000000000E000f) : ( 1.00000000000000000E000f + g_Light2ShadowBias*(_TMP97 -  1.00000000000000000E000f)).xxxx);
		_linfos0092[1]._color7.w = (abs(_linfos0092[0]._color7.w - 1) / (_a0121 + 0.0000001));
        _linfos3[0]._color7 = _linfos0092[0]._color7;
        _linfos3[1]._color7 = _linfos0092[1]._color7;
    } // end if
#endif
    _diffuse0103 = float4(  0.00000000000000000E000f,  0.00000000000000000E000f,  0.00000000000000000E000f,  0.00000000000000000E000f);
    if (g_UseAmbientMap) { // if begin
        _TMP150105._11_12_13 = float3(g_EnvCubeRot.x,  0.00000000000000000E000f, g_EnvCubeRot.y);
        _TMP150105._31_32_33 = float3(g_EnvCubeRot.z,  0.00000000000000000E000f, g_EnvCubeRot.x);
        _r0109 = _TMP78.x*_TMP150105._11_12_13;
        _r0109 = _r0109 + _TMP78.z*float3(  0.00000000000000000E000f,  1.00000000000000000E000f,  0.00000000000000000E000f);
        _r0109 = _r0109 + _TMP78.y*_TMP150105._31_32_33;
        _a0111 = texCUBElod(g_AmbientSampler, float4(_r0109.x, _r0109.y, _r0109.z, g_AmbientBlur));
        _TMP110 = float4(pow(_a0111.x, g_AmbientContrast.x), pow(_a0111.y, g_AmbientContrast.x), pow(_a0111.z, g_AmbientContrast.x), pow(_a0111.w, g_AmbientContrast.x));
        _diffuse0103 = _TMP110*g_AmbientStrength;
    } // end if
    _diffuse0112 = _diffuse0103;
    _specular0112 = float4(  0.00000000000000000E000f,  0.00000000000000000E000f,  0.00000000000000000E000f,  0.00000000000000000E000f);
    _i10112 = 0;
    for (; _i10112 < g_UsedLights; _i10112 = _i10112 + 1) { // for begin
        _linf10112._color7 = _linfos3[_i10112]._color7;
        _linf10112._LdotNR = _linfos3[_i10112]._LdotNR;
        _diffuse0112 = _diffuse0112 + _linf10112._LdotNR.xxxx*_linf10112._color7;
        _TMP114 = float4(pow(_linf10112._LdotNR.y, _pix0022._gloss.x), pow(_linf10112._LdotNR.y, _pix0022._gloss.y), pow(_linf10112._LdotNR.y, _pix0022._gloss.z), pow(_linf10112._LdotNR.y, _pix0022._gloss.w));
        _TMP116 = 1-saturate(_linf10112._color7.w);
        _specular0112 = _specular0112 + (_TMP114*_linf10112._color7)*_TMP116*_linf10112._LdotNR.x;
    } // end for
    _diffusecolor0102 = _diffuse0112*_pix0022._diffuse4;
    if (g_EmissiveMode == 1) { // if begin
        _outcolor0102 = _diffusecolor0102 + _pix0022._emissive;
    } else {
        if (g_EmissiveMode == 2) { // if begin
            _outcolor0102 = (_diffuse0112 + _pix0022._emissive)*_pix0022._diffuse4;
        } else {
            _outcolor0102 = max(_diffusecolor0102, _pix0022._emissive);
        } // end if
    } // end if
    _color0122 = _outcolor0102;
    _light0122 = _diffuse0112;
    if (g_UseReflectionMap) { // if begin
        _TMP150124._11_12_13 = float3(g_EnvCubeRot.x,  0.00000000000000000E000f, g_EnvCubeRot.y);
        _TMP150124._31_32_33 = float3(g_EnvCubeRot.z,  0.00000000000000000E000f, g_EnvCubeRot.x);
        _r0128 = _env0067._wReflect.x*_TMP150124._11_12_13;
        _r0128 = _r0128 + _env0067._wReflect.z*float3(  0.00000000000000000E000f,  1.00000000000000000E000f,  0.00000000000000000E000f);
        _r0128 = _r0128 + _env0067._wReflect.y*_TMP150124._31_32_33;
        _cubemap10122 = texCUBElod(g_ReflectionSampler, float4(_r0128.x, _r0128.y, _r0128.z, g_ReflectionBlur + _pix0022._refblur));
        _TMP129 = float4(pow(_cubemap10122.x, g_ReflectionContrast.x), pow(_cubemap10122.y, g_ReflectionContrast.x), pow(_cubemap10122.z, g_ReflectionContrast.x), pow(_cubemap10122.w, g_ReflectionContrast.x));
        _factor10122 = pow(_env0067._OneMinusNdotE, g_SpecularRefFPower).xxxx;
        _factor10122 = _factor10122 + g_SpecularRefFBias.xxxx;
        _factor10122 = _factor10122*_pix0022._refl;
        if (g_UseSpecularRefDecal) { // if begin
            _t0132 = saturate(_factor10122);
            _color0122 = _outcolor0102 + _t0132*(_TMP129 - _outcolor0102);
        } else {
            _color0122 = _outcolor0102 + _TMP129*_factor10122;
            _light0122 = _diffuse0112 + _TMP129*_factor10122;
        } // end if
    } // end if
    _specular0102 = _specular0112*_pix0022._specular3;
    _speccontrib0102 = dot(float3(  3.00000011920928960E-001f,  5.89999973773956300E-001f,  1.09999999403953550E-001f), _specular0102.xyz);
    _specular0102 = g_UseSpecularAdd ? _specular0102 : (_diffusecolor0102*_specular0102)* 1.00000000000000000E001f;
    _diffcontrib0102 = dot(float3(  3.00000011920928960E-001f,  5.89999973773956300E-001f,  1.09999999403953550E-001f), _light0122.xyz)*g_AlphaStrength2;
    _transp0102 =  1.00000000000000000E000f - saturate(_pix0022._diffuse4.w*_pix0022._opacity);
    if (abs(g_AlphaStrength2) <  9.99999974737875160E-005f) { // if begin
        _a0138 = _color0122.xyz + _specular0102.xyz;
        _t0138 = saturate(_transp0102 - _diffcontrib0102);
        _outcolor0102.xyz = _a0138 + _t0138*(_specular0102.xyz - _a0138);
    } else {
        _outcolor0102.xyz = _color0122.xyz + _specular0102.xyz;
    } // end if
    _outcolor0102.w = g_UseSpecularOpacity ?  0.00000000000000000E000f : _speccontrib0102*_transp0102;
    _diffcontrib0102 = _diffcontrib0102 + (g_UseSpecularOpacity ?  0.00000000000000000E000f : _speccontrib0102*g_AlphaStrength2);
    _color0139 = _outcolor0102;
    _diffalpha0139 = ( 1.00000000000000000E000f - _transp0102) + _diffcontrib0102*_pix0022._diffuse4.w;
    if (g_UseDiffuseFresnel || g_UseAlphaFresnel) { // if begin
        _power10139 = float4(g_DiffuseFPower.x, g_DiffuseFPower.x, g_DiffuseFPower.x, g_AlphaFPower);
        _bias10139 = float4(g_DiffuseFBias.x, g_DiffuseFBias.x, g_DiffuseFBias.x, g_AlphaFBias);
        _strength10139 = float4(g_DiffuseFStrength.x, g_DiffuseFStrength.x, g_DiffuseFStrength.x, g_AlphaFStrength);
        _TMP140 = float4(pow(_env0067._OneMinusNdotE.x, _power10139.x), pow(_env0067._OneMinusNdotE.x, _power10139.y), pow(_env0067._OneMinusNdotE.x, _power10139.z), pow(_env0067._OneMinusNdotE.x, _power10139.w));
        _factor10139 = _TMP140 + _bias10139;
        _factor10139 = _factor10139*_strength10139;
        if (!g_UseDiffuseFresnel) { // if begin
            _factor10139.xyz = float3(  0.00000000000000000E000f,  0.00000000000000000E000f,  0.00000000000000000E000f);
        } // end if
        _color0143 = g_DiffuseFTintColor;
        _TMP148 = float3(pow(g_DiffuseFTintColor.x,  2.20000004768371580E000f), pow(g_DiffuseFTintColor.y,  2.20000004768371580E000f), pow(g_DiffuseFTintColor.z,  2.20000004768371580E000f));
        _color0147.xyz = _TMP148*(float3) (g_DiffuseFTintColor.xyz >= float3(  9.99999974737875160E-005f,  9.99999974737875160E-005f,  9.99999974737875160E-005f));
        _color0143.xyz = _color0147.xyz;
        _t0145 = saturate(_factor10139);
        _clr10139 = _outcolor0102 + _t0145*(_color0143 - _outcolor0102);
        _color0139.xyz = _clr10139.xyz;
        if (g_UseAlphaFresnel) { // if begin
            _color0139.w = max(_clr10139.w*_diffalpha0139, _outcolor0102.w);
        } // end if
    } // end if
    if (!g_UseAlphaFresnel) { // if begin
        _color0139.w = _color0139.w + _diffalpha0139;
    } // end if
    _color0153 = _color0139;
    _a0157 = saturate(_color0139.xyz) * LIGHT_SCALE;
    _TMP156 = float3(pow(_a0157.x,  4.54545438289642330E-001f), pow(_a0157.y,  4.54545438289642330E-001f), pow(_a0157.z,  4.54545438289642330E-001f));
    _color0153.xyz = _TMP156;
    _outcolor0102 = _color0153;
    if (g_UseAlphaTest) { // if begin
        _outcolor0102.w =  1.00000000000000000E000f;
    } // end if
    return _outcolor0102;
} // main end


#endif
// PRECOMPILED BARRIER
///////////////////////////////////////////////////////////////
//=============================================================
///////////////////////////////////////////////////////////////


//-------------------------------------------------
//  techniques 
//-------------------------------------------------

#ifdef ALPHA_TWOSIDED
	#define ALPHATWOSIDED_TECHNIQUE
#else
	#undef ALPHATWOSIDED_TECHNIQUE
#endif




technique Standard_PS3
{
#ifdef LAYDEPTHFIRST
	pass PD
	{
		AlphaBlendEnable = FALSE;
		ColorWriteEnable = 0;
		CullMode = CW;
		ZWriteEnable = TRUE;
		ZFunc = LESSEQUAL;
		ZEnable = TRUE;

		VertexShader   = compile vs_3_0 Main_Depth_VS11();
		PixelShader = compile ps_3_0 LayDepth();
	}
#endif
	pass P0
	{
		AlphaBlendEnable = ALPHA_STANDARD;
		CullMode = CW;
		ColorWriteEnable = 0xFFFFFFFF;
#ifdef LAYDEPTHFIRST
		ZWriteEnable = FALSE;
#else
		ZWriteEnable = TRUE;
#endif
		ZFunc = LESSEQUAL;
		ZEnable = TRUE;
		SrcBlend = SRCALPHA;
		DestBlend = INVSRCALPHA;
		BlendOp = ADD;

		VertexShader   = compile vs_3_0 Main_3Light_VS11();
		PixelShader = compile ps_3_0 Main_Standard_PS3(SHADOW_STANDARD,false);
	}
}

#ifdef ALPHATWOSIDED_TECHNIQUE
technique Standard_AlphaBlend_TwoSided_PS3
{
	pass P0
	{
		AlphaBlendEnable = TRUE;
		CullMode = CCW;
		ZWriteEnable = FALSE;
		ZFunc = LESSEQUAL;
		ZEnable = TRUE;
		SrcBlend = SRCALPHA;
		DestBlend = INVSRCALPHA;
		BlendOp = ADD;
		
		VertexShader   = compile vs_3_0 Main_3Light_VS11();
		PixelShader = compile ps_3_0 Main_Standard_PS3(SHADOW_STANDARD,true);
	}

	pass P1
	{
		AlphaBlendEnable = TRUE;
		CullMode = CW;
		ZWriteEnable = FALSE;
		ZFunc = LESSEQUAL;
		ZEnable = TRUE;
		SrcBlend = SRCALPHA;
		DestBlend = INVSRCALPHA;
		BlendOp = ADD;
		
		VertexShader   = compile vs_3_0 Main_3Light_VS11();
		PixelShader = compile ps_3_0 Main_Standard_PS3(SHADOW_STANDARD,false);
	}
}
#endif

/*
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR 
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR 
OTHER DEALINGS IN THE SOFTWARE.
*/

