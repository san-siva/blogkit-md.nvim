import type { Metadata } from 'next';

import { BlogPost } from '@san-siva/blogkit-md';

import { BLOGKIT_MD_NVIM, SITE_URL, generateMetadata } from './data';

export const metadata: Metadata = generateMetadata(BLOGKIT_MD_NVIM);

export default function Home() {
	return (
		<BlogPost
			filePath="../README.md"
			jsonLd={{
				'@context': 'https://schema.org',
				'@type': 'SoftwareApplication',
				name: BLOGKIT_MD_NVIM.title,
				description: BLOGKIT_MD_NVIM.desc,
				datePublished: BLOGKIT_MD_NVIM.isoDate,
				author: {
					'@type': 'Person',
					name: 'Santhosh Siva',
					url: 'https://santhoshsiva.dev',
				},
				url: SITE_URL,
				applicationCategory: 'DeveloperApplication',
				operatingSystem: 'macOS, Linux, Windows',
			}}
		/>
	);
}
