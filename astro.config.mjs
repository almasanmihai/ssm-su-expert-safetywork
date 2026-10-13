// @ts-check
import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
	site: 'https://tcasafework.ro',
	trailingSlash: 'always',
	integrations: [
		sitemap({
			changefreq: 'monthly',
			priority: 0.7,
			lastmod: new Date(),
			filter: (page) => !page.includes('/404') && !page.includes('contact.php'),
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
					item.changefreq = 'monthly';
				} else if (url.includes('/contact')) {
					item.priority = 0.8;
				} else if (url.includes('/despre')) {
					item.priority = 0.6;
				} else if (url.includes('/confidentialitate')) {
					item.priority = 0.3;
					item.changefreq = 'yearly';
				}
				return item;
			},
		}),
	],
});
