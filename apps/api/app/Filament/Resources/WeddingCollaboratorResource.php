<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\WeddingCollaboratorResource\Pages;
use App\Models\WeddingCollaborator;
use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;

class WeddingCollaboratorResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.users';

    protected static ?string $model = WeddingCollaborator::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-user-plus';
    protected static string|\UnitEnum|null $navigationGroup = 'Platform';
    protected static ?int $navigationSort = 4;
    protected static ?string $recordTitleAttribute = 'role';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Collaborator')->columns(2)->schema([
                Forms\Components\Select::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->searchable()->required()->label('Wedding'),
                Forms\Components\Select::make('user_id')
                    ->relationship('user', 'email')
                    ->searchable()->required()->label('User'),
                Forms\Components\Select::make('role')
                    ->options(['owner' => 'Owner', 'partner' => 'Partner', 'planner' => 'Planner', 'collaborator' => 'Collaborator'])
                    ->default('collaborator')->required(),
                Forms\Components\DateTimePicker::make('accepted_at')->native(false)->label('Accepted at'),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.email')->label('User')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')->label('Wedding')->searchable(),
                Tables\Columns\TextColumn::make('role')->badge()
                    ->color(fn ($s) => match ($s) {
                        'owner' => 'danger', 'partner' => 'warning',
                        'planner' => 'info', default => 'gray',
                    }),
                Tables\Columns\IconColumn::make('accepted_at')
                    ->label('Accepted')
                    ->boolean()
                    ->getStateUsing(fn ($record) => $record->accepted_at !== null),
                Tables\Columns\TextColumn::make('created_at')->since()->sortable()->label('Invited'),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('role')
                    ->options(['owner' => 'Owner', 'partner' => 'Partner', 'planner' => 'Planner', 'collaborator' => 'Collaborator']),
            ])
            ->actions([Actions\EditAction::make(), Actions\DeleteAction::make()])
            ->bulkActions([Actions\BulkActionGroup::make([Actions\DeleteBulkAction::make()])]);
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListWeddingCollaborators::route('/'),
            'create' => Pages\CreateWeddingCollaborator::route('/create'),
            'edit'   => Pages\EditWeddingCollaborator::route('/{record}/edit'),
        ];
    }

    public static function getNavigationLabel(): string { return 'Collaborators'; }
}
