<?php

namespace App\Filament\Pages;

use App\Filament\Widgets\ReliabilityStatsWidget;
use App\Filament\Widgets\StaleMessagesWidget;
use App\Filament\Widgets\TokenExpiryRiskWidget;
use Filament\Pages\Page;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Schema;
use UnitEnum;

class ReliabilityConsole extends Page
{
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-shield-check';
    protected static string|UnitEnum|null $navigationGroup = 'Operations';
    protected static ?string $navigationLabel = 'Reliability Console';
    protected static ?int $navigationSort = 17;
    protected static ?string $title = 'Reliability Console';

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
            ReliabilityStatsWidget::class,
            StaleMessagesWidget::class,
            TokenExpiryRiskWidget::class,
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
