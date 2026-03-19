import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
	output: 'export',
	trailingSlash: true,
	transpilePackages: ['@san-siva/blogkit-md'],
};

export default nextConfig;
