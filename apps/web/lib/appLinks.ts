// Store links for the mobile app. The Play Store listing is live, so it has a
// hardcoded default; override via env if the package/URL ever changes. iOS is
// not published yet — leave NEXT_PUBLIC_APP_STORE_URL blank and the UI shows a
// "coming soon" state instead of a dead link.
export const PLAY_STORE_URL =
  process.env.NEXT_PUBLIC_PLAY_STORE_URL ||
  'https://play.google.com/store/apps/details?id=com.udowedding.udo_mobile';

export const APP_STORE_URL = process.env.NEXT_PUBLIC_APP_STORE_URL || null;
