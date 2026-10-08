import type { MetadataRoute } from 'next';

const SITE = 'https://udowedding.com';

export default function sitemap(): MetadataRoute.Sitemap {
  const now = new Date();
  return [
    { url: `${SITE}/`, lastModified: now, changeFrequency: 'weekly', priority: 1 },
    { url: `${SITE}/features`, lastModified: now, changeFrequency: 'monthly', priority: 0.8 },
    { url: `${SITE}/how-it-works`, lastModified: now, changeFrequency: 'monthly', priority: 0.7 },
    { url: `${SITE}/pricing`, lastModified: now, changeFrequency: 'monthly', priority: 0.8 },
    { url: `${SITE}/download`, lastModified: now, changeFrequency: 'monthly', priority: 0.6 },
    { url: `${SITE}/privacy`, lastModified: now, changeFrequency: 'yearly', priority: 0.3 },
    { url: `${SITE}/terms`, lastModified: now, changeFrequency: 'yearly', priority: 0.3 },
  ];
}
