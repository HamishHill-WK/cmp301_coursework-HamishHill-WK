#pragma once
#include "DXF.h"
#include "BaseShader.h"

using namespace std;
using namespace DirectX;

class texShader : public BaseShader
{
public:
	texShader(ID3D11Device* device, HWND hwnd);
	~texShader();

	void setShaderParameters(ID3D11DeviceContext* deviceContext, const XMMATRIX& world, const XMMATRIX& view, const XMMATRIX& projection, ID3D11ShaderResourceView* texture, Light* light);

private:
	void initShader(const wchar_t* vs, const wchar_t* ps);

private:
	ID3D11Buffer* matrixBuffer;
	ID3D11SamplerState* sampleState;
};

