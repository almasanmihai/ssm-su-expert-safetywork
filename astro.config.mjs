// @ts-check
import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
	site: 'https://tcasafework.ro',
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
				if (url === 'https://tcasafework.ro/' || url === 'https://tcasafework.ro') {
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
