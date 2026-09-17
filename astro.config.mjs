// @ts-check
import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

// GitHub Pages project site: https://<user>.github.io/<repo>/
export default defineConfig({
	site: 'https://almasanmihai.github.io',
	base: '/ssm-su-expert-safetywork/',
	integrations: [
		sitemap({
			changefreq: 'monthly',
			priority: 0.7,
			lastmod: new Date(),
			i18n: {
				defaultLocale: 'ro',
				locales: {
					ro: 'ro-RO',
				},
			},
			serialize(item) {
				const url = item.url;
				if (url.endsWith('/ssm-su-expert-safetywork/') || url.endsWith('/ssm-su-expert-safetywork')) {
					item.priority = 1.0;
					item.changefreq = 'weekly';
				} else if (url.includes('/servicii')) {
					item.priority = 0.9;
				} else if (url.includes('/contact')) {
					item.priority = 0.8;
				}
				return item;
			},
		}),
	],
});
