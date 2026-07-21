<?php

namespace App\Providers\Filament;

use App\Filament\Resources\AccommodationOptionResource;
use App\Filament\Resources\AuditLogResource;
use App\Filament\Resources\BlogPostResource;
use App\Filament\Resources\BudgetItemResource;
use App\Filament\Resources\BudgetPaymentScheduleResource;
use App\Filament\Resources\EmailTemplateResource;
use App\Filament\Resources\FailedJobResource;
use App\Filament\Resources\FaqResource;
use App\Filament\Resources\GalleryAssetResource;
use App\Filament\Resources\GuestMessageDeliveryResource;
use App\Filament\Resources\GuestExperienceConfigResource;
use App\Filament\Resources\GuestResource;
use App\Filament\Resources\GuestTokenResource;
use App\Filament\Resources\IdempotencyKeyResource;
use App\Filament\Resources\InvitationCampaignResource;
use App\Filament\Resources\LiveUpdateResource;
use App\Filament\Resources\MessageResource;
use App\Filament\Resources\RegistryContributionResource;
use App\Filament\Resources\SavedFilterResource;
use App\Filament\Resources\SeatingTableResource;
use App\Filament\Resources\SmartAlertResource;
use App\Filament\Resources\SubscriptionResource;
use App\Filament\Resources\SupportTicketResource;
use App\Filament\Resources\TaskResource;
use App\Filament\Resources\TestimonialResource;
use App\Filament\Resources\ThankYouRecordResource;
use App\Filament\Resources\TimelineItemResource;
use App\Filament\Resources\TransportGroupResource;
use App\Filament\Resources\UserResource;
use App\Filament\Resources\VendorResource;
use App\Filament\Resources\WeddingCollaboratorResource;
use App\Filament\Resources\WeddingResource;
use App\Filament\Pages\LiveCommandCenter;
use App\Filament\Pages\ReliabilityConsole;
use App\Filament\Widgets\ActiveSmartAlertsWidget;
use App\Filament\Widgets\LiveWeddingsWidget;
use App\Filament\Widgets\OperationsHealthWidget;
use App\Filament\Widgets\RecentSignupsWidget;
use App\Filament\Widgets\StatsOverviewWidget;
use App\Filament\Widgets\WeddingsChartWidget;
use Filament\Http\Middleware\Authenticate;
use Filament\Http\Middleware\DisableBladeIconComponents;
use Filament\Http\Middleware\DispatchServingFilamentEvent;
use Filament\Pages;
use Filament\Panel;
use Filament\PanelProvider;
use Filament\Support\Colors\Color;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken;
use Illuminate\Routing\Middleware\SubstituteBindings;
use Illuminate\Session\Middleware\AuthenticateSession;
use Illuminate\Session\Middleware\StartSession;
use Illuminate\View\Middleware\ShareErrorsFromSession;

class AdminPanelProvider extends PanelProvider
{
    public function panel(Panel $panel): Panel
    {
        return $panel
            ->default()
            ->id('admin')
            ->path('admin')
            ->login()
            ->colors([
                'primary' => Color::hex('#285301'),
                'danger'  => Color::hex('#D45D78'),
                'warning' => Color::Amber,
                'success' => Color::Green,
                'info'    => Color::Blue,
            ])
            ->brandName('Udo Admin')
            ->brandLogo(null)
            ->favicon(null)
            ->darkMode(false)
            ->resources([
                // Platform
                UserResource::class,
                WeddingResource::class,
                GuestResource::class,
                WeddingCollaboratorResource::class,
                // Operations
                InvitationCampaignResource::class,
                MessageResource::class,
                GuestMessageDeliveryResource::class,
                GuestExperienceConfigResource::class,
                GuestTokenResource::class,
                VendorResource::class,
                TaskResource::class,
                GalleryAssetResource::class,
                LiveUpdateResource::class,
                SmartAlertResource::class,
                BudgetItemResource::class,
                BudgetPaymentScheduleResource::class,
                TimelineItemResource::class,
                AuditLogResource::class,
                SavedFilterResource::class,
                FailedJobResource::class,
                IdempotencyKeyResource::class,
                // Logistics
                SeatingTableResource::class,
                AccommodationOptionResource::class,
                TransportGroupResource::class,
                // Finance & Support
                SubscriptionResource::class,
                RegistryContributionResource::class,
                ThankYouRecordResource::class,
                SupportTicketResource::class,
                // Content
                BlogPostResource::class,
                TestimonialResource::class,
                FaqResource::class,
                EmailTemplateResource::class,
            ])
            ->pages([
                Pages\Dashboard::class,
                LiveCommandCenter::class,
                ReliabilityConsole::class,
            ])
            ->widgets([
                OperationsHealthWidget::class,
                ActiveSmartAlertsWidget::class,
                LiveWeddingsWidget::class,
                StatsOverviewWidget::class,
                WeddingsChartWidget::class,
                RecentSignupsWidget::class,
            ])
            ->middleware([
                EncryptCookies::class,
                AddQueuedCookiesToResponse::class,
                StartSession::class,
                AuthenticateSession::class,
                ShareErrorsFromSession::class,
                VerifyCsrfToken::class,
                SubstituteBindings::class,
                DisableBladeIconComponents::class,
                DispatchServingFilamentEvent::class,
            ])
            ->authMiddleware([
                Authenticate::class,
            ]);
    }
}
