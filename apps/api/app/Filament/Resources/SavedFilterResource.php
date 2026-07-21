<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\SavedFilterResource\Pages;
use App\Models\SavedFilter;
use BackedEnum;
use Filament\Actions;
use Filament\Infolists;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables;
use Filament\Tables\Table;
use UnitEnum;

class SavedFilterResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.operations';

    protected static ?string $model = SavedFilter::class;
    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-funnel';
    protected static string|UnitEnum|null $navigationGroup = 'Operations';
    protected static ?int $navigationSort = 16;
    protected static ?string $recordTitleAttribute = 'name';

    public static function canCreate(): bool
    {
        return false;
    }

    public static function canEdit(\Illuminate\Database\Eloquent\Model $record): bool
    {
        return false;
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Saved filter')->columns(3)->schema([
                Infolists\Components\TextEntry::make('name'),
                Infolists\Components\TextEntry::make('resource_type')->badge()->color('info'),
                Infolists\Components\TextEntry::make('wedding.couple_name_primary')->label('Wedding')->default('-'),
                Infolists\Components\TextEntry::make('user.email')->label('Created by')->copyable()->default('-'),
                Infolists\Components\IconEntry::make('is_default')->boolean()->label('Default'),
                Infolists\Components\TextEntry::make('created_at')->dateTime()->label('Created'),
            ]),
            \Filament\Schemas\Components\Section::make('Criteria')->schema([
                Infolists\Components\TextEntry::make('criteria')
                    ->label('')
                    ->formatStateUsing(fn ($state) => json_encode($state ?: [], JSON_PRETTY_PRINT))
                    ->columnSpanFull(),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('resource_type')->label('Resource')->badge()->color('info'),
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')->label('Wedding')->searchable()->default('-'),
                Tables\Columns\TextColumn::make('user.email')->label('Created by')->searchable()->default('-'),
                Tables\Columns\IconColumn::make('is_default')->boolean()->label('Default'),
                Tables\Columns\TextColumn::make('created_at')->since()->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('resource_type')
                    ->options(fn () => SavedFilter::query()->distinct()->pluck('resource_type', 'resource_type')->all()),
                Tables\Filters\SelectFilter::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->searchable()
                    ->label('Wedding'),
            ])
            ->actions([
                Actions\ViewAction::make(),
                Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Actions\BulkActionGroup::make([
                    Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->emptyStateHeading('No saved filters')
            ->emptyStateDescription('Filters appear here once a wedding owner saves one from their own dashboard.');
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListSavedFilters::route('/'),
            'view'  => Pages\ViewSavedFilter::route('/{record}'),
        ];
    }
}
