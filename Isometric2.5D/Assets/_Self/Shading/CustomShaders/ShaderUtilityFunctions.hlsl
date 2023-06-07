float3 MaptoZeroOne(float3 color)
{
	return (color + 1) / 2;
}

float BytetoOne(int number)
{
	return float(number) / 255;
}

float3 BytetoOne(int3 vect)
{
	return float3(BytetoOne(vect.x),BytetoOne(vect.y),BytetoOne(vect.z));
}