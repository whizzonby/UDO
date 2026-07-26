import GalleryUploadPortal from '@/components/guest/GalleryUploadPortal';

export default function GalleryUploadPage({ params }: { params: { token: string } }) {
  return <GalleryUploadPortal token={params.token} />;
}
