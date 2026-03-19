export const SITE_URL = 'https://blogkit-md-nvim.santhoshsiva.dev';

export type PageMeta = {
	title: string;
	desc: string;
	publishedOn: string;
	isoDate: string;
	keywords: string[];
};

export const generateMetadata = (meta: PageMeta) => ({
	title: meta.title,
	description: meta.desc,
	keywords: meta.keywords,
	authors: [{ name: 'Santhosh Siva' }],
	alternates: {
		canonical: `${SITE_URL}/`,
	},
	openGraph: {
		title: meta.title,
		description: meta.desc,
		type: 'website' as const,
		url: `${SITE_URL}/`,
	},
	twitter: {
		card: 'summary_large_image' as const,
		title: meta.title,
		description: meta.desc,
	},
});

export const BLOGKIT_MD_NVIM: PageMeta = {
	title: 'blogkit-md.nvim — Live Markdown Preview for Neovim',
	desc: 'A Neovim plugin that launches a live preview of the current markdown buffer using blogkit-md.',
	publishedOn: 'March 19, 2026',
	isoDate: '2026-03-19',
	keywords: [
		'neovim',
		'plugin',
		'markdown',
		'preview',
		'blogkit',
		'live reload',
		'lua',
	],
};
