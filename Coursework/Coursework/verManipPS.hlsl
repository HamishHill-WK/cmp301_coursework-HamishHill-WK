
Texture2D texture0 : register(t0);
SamplerState sampler0 : register(s0);

Texture2D depthMapTexture : register(t1);
SamplerState shadowSampler : register(s1);

cbuffer LightBuffer : register(b0)
{
    //float3 lightDirection;
    //float pad;
    //float4 ambient;
    //float4 diffuseColour;
    //float3 position;
    //float pad1;
    //float3 atten;
    //float pad2;    
    
    float3 lightDirection;
    float pad;
    float4 ambient[2];
    float4 diffuseColour[2];
    float3 position;
    float pad1;
    float3 atten;
    bool norms;
};

struct InputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
    float3 worldPosition : TEXCOORD1;
    float4 lightViewPos : TEXCOORD2;
};


float4 calculateLighting(float3 lightDirection, float3 normal, float4 diffuse)
{
    float intensity = saturate(dot(normal, lightDirection));
    float4 colour = saturate(diffuse * intensity);
    return colour;
}

// Is the gemoetry in our shadow map
bool hasDepthData(float2 uv)
{
    if (uv.x < 0.f || uv.x > 1.f || uv.y < 0.f || uv.y > 1.f)
    {
        return false;
    }
    return true;
}

bool isInShadow(Texture2D sMap, float2 uv, float4 lightViewPosition, float bias)
{
    // Sample the shadow map (get depth of geometry)
    float depthValue = sMap.Sample(shadowSampler, uv).r;
	// Calculate the depth from the light.
    float lightDepthValue = lightViewPosition.z / lightViewPosition.w;
    lightDepthValue -= bias;

	// Compare the depth of the shadow map value and the depth of the light to determine whether to shadow or to light this pixel.
    if (lightDepthValue < depthValue)
    {
        return false;
    }
    return true;
}

float2 getProjectiveCoords(float4 lightViewPosition)
{
    // Calculate the projected texture coordinates.
    float2 projTex = lightViewPosition.xy / lightViewPosition.w;
    projTex *= float2(0.5, -0.5);
    projTex += float2(0.5f, 0.5f);
    return projTex;
}

float4 main(InputType input) : SV_TARGET
{
    if(norms)
    {
        float4 colour = float4(input.normal.x, input.normal.y, input.normal.z, 0.0f);
        return colour;
    }
    
    float4 textureColour;
    float shadowMapBias = 0.01f;
   // float4 colour = float4(0.f, 0.f, 0.f, 1.f);

    textureColour = texture0.Sample(sampler0, (input.tex * 2));
    float2 pTexCoord = getProjectiveCoords(input.lightViewPos);
	
    float d; //array of distances from source to pixel -hh
    float attenMod; //"" attenuation modifiers -hh
    float3 lightVector; //"" normalized light vectors -hh
	
    //d = length(position[1].xyz - input.worldPosition);
    d = length(position.xyz - input.worldPosition);

    attenMod = 1 / ((atten.x + (atten.y * d)) + (atten.z * (d * d)));
	
    //   lightVector = normalize(position[1].xyz - input.worldPosition);
    lightVector = normalize(position.xyz - input.worldPosition);
	
    float4 finalDif = float4(0.f, 0.f, 0.f, 1.f);
	
  //  finalDif = /*(ambient + calculateLighting(-lightDirection[0], input.normal, diffuseColour[0])) +*/
  //  (calculateLighting(lightVector, input.normal, diffuseColour[1]) * attenMod);    
    
    //finalDif = calculateLighting(-lightDirection, input.normal, diffuseColour[0]) +
    //(calculateLighting(lightVector, input.normal, diffuseColour[1]) * attenMod) + ambient[0] + ambient[1];       
    
    
    if (hasDepthData(pTexCoord))
    {
        // Has depth map data
        if (!isInShadow(depthMapTexture, pTexCoord, input.lightViewPos, shadowMapBias))
        {
            // is NOT in shadow, therefore light
            finalDif = calculateLighting(-lightDirection, input.normal, diffuseColour[0]);
            
        }
    }
    
    finalDif = saturate(finalDif + (calculateLighting(lightVector, input.normal, diffuseColour[1]) * attenMod) + ambient[0] + ambient[1]);
    return saturate(finalDif * textureColour);
}

