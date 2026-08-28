<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;
use App\Filament\Resources\StoreLinkClickResource\Pages;
use App\Filament\Widgets\StoreClicksStatsWidget;
use App\Models\StoreLinkClick;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Model;
use UnitEnum;

class StoreLinkClickResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.operations';

    protected static ?string $model = StoreLinkClick::class;
    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-cursor-arrow-ripple';
    protected static string|UnitEnum|null $navigationGroup = 'Growth';
    protected static ?string $navigationLabel = 'App Link Clicks';
    protected static ?int $navigationSort = 10;
    protected static ?string $recordTitleAttribute = 'id';

    public static function canCreate(): bool
    {
        return false;
    }

    public static function canEdit(Model $record): bool
    {
        return false;
    }

    public static function canDelete(Model $record): bool
    {
        return false;
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('created_at')->label('When')->since()->dateTimeTooltip()->sortable(),
                Tables\Columns\TextColumn::make('platform')->badge()->color('gray')->sortable(),
                Tables\Columns\TextColumn::make('source_path')->label('Page')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('link_location')->label('Placement')->badge()->color('gray')->searchable()->toggleable(),
                Tables\Columns\TextColumn::make('utm_source')->label('Source')->searchable()->sortable()->placeholder('—'),
                Tables\Columns\TextColumn::make('utm_medium')->label('Medium')->searchable()->toggleable()->placeholder('—'),
                Tables\Columns\TextColumn::make('utm_campaign')->label('Campaign')->searchable()->sortable()->placeholder('—'),
                Tables\Columns\TextColumn::make('utm_content')->label('Content')->searchable()->toggleable(isToggledHiddenByDefault: true)->placeholder('—'),
                Tables\Columns\TextColumn::make('country')->toggleable()->placeholder('—'),
                Tables\Columns\TextColumn::make('referrer')->limit(40)->tooltip(fn ($state) => $state)->toggleable(isToggledHiddenByDefault: true)->placeholder('direct'),
                Tables\Columns\TextColumn::make('user_agent')->label('Device')->limit(40)->tooltip(fn ($state) => $state)->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('platform')
                    ->options(['android' => 'Android', 'ios' => 'iOS', 'web' => 'Web']),
                Tables\Filters\SelectFilter::make('source_path')
                    ->label('Page')
                    ->options(fn () => StoreLinkClick::query()->whereNotNull('source_path')->distinct()->orderBy('source_path')->pluck('source_path', 'source_path')->all()),
                Tables\Filters\SelectFilter::make('utm_source')
                    ->label('Source')
                    ->options(fn () => StoreLinkClick::query()->whereNotNull('utm_source')->distinct()->orderBy('utm_source')->pluck('utm_source', 'utm_source')->all()),
                Tables\Filters\Filter::make('created_at')
                    ->form([
                        \Filament\Forms\Components\DatePicker::make('from')->native(false),
                        \Filament\Forms\Components\DatePicker::make('until')->native(false),
                    ])
                    ->query(fn ($query, array $data) => $query
                        ->when($data['from'] ?? null, fn ($q, $date) => $q->whereDate('created_at', '>=', $date))
                        ->when($data['until'] ?? null, fn ($q, $date) => $q->whereDate('created_at', '<=', $date))),
            ])
            ->actions([])
            ->bulkActions([])
            ->emptyStateHeading('No app-link clicks yet')
            ->emptyStateDescription('Taps on the "Get the App" / Google Play links across the marketing site will appear here.')
            ->emptyStateIcon('heroicon-o-cursor-arrow-ripple');
    }

    public static function getWidgets(): array
    {
        return [
            StoreClicksStatsWidget::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListStoreLinkClicks::route('/'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        $today = static::getModel()::whereDate('created_at', now()->toDateString())->count();

        return $today ?: null;
    }
}
