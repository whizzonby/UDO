import type { MetadataRoute } from 'next';

export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: '*',
      allow: '/',
      // Private areas: dashboards, auth flows and per-guest portal links.
      disallow: ['/dashboard', '/g/', '/invite', '/upload', '/checkout', '/onboarding', '/api/', '/auth', '/reset-password'],
    },
    sitemap: 'https://udowedding.com/sitemap.xml',
  };
}
