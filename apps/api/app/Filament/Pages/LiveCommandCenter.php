<?php

namespace App\Filament\Pages;

use App\Filament\Widgets\LiveCommandCenterWeddingsWidget;
use App\Filament\Widgets\UnresolvedLiveIncidentsWidget;
use App\Filament\Widgets\VipReadinessWidget;
use Filament\Pages\Page;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Schema;
use UnitEnum;

class LiveCommandCenter extends Page
{
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-bolt';
    protected static string|UnitEnum|null $navigationGroup = 'Operations';
    protected static ?string $navigationLabel = 'Live Command Center';
    protected static ?int $navigationSort = 1;
    protected static ?string $title = 'Live Command Center';

    public static function canAccess(): bool
    {
        return auth()->user()?->can('admin.operations') ?? false;
    }

    /**
     * @return array<class-string>
     */
    public function getWidgets(): array
    {
        return [
            LiveCommandCenterWeddingsWidget::class,
            UnresolvedLiveIncidentsWidget::class,
            VipReadinessWidget::class,
        ];
    }

    public function getColumns(): int|array
    {
        return 1;
    }

    public function content(Schema $schema): Schema
    {
        return $schema->components([
            Grid::make($this->getColumns())->schema($this->getWidgetsSchemaComponents($this->getWidgets())),
        ]);
    }
}
