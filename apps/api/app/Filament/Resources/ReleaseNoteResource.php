<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\ReleaseNoteResource\Pages;
use App\Models\ReleaseNote;
use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;
use BackedEnum;
use UnitEnum;

class ReleaseNoteResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.content';

    protected static ?string $model = ReleaseNote::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-sparkles';
    protected static string|\UnitEnum|null $navigationGroup = 'Content';
    protected static ?int $navigationSort = 6;
    protected static ?string $navigationLabel = 'Release Notes';
    protected static ?string $recordTitleAttribute = 'title';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            Forms\Components\TextInput::make('version')->required()->maxLength(30)->columnSpanFull(),
            Forms\Components\TextInput::make('title')->required()->maxLength(150)->columnSpanFull(),
            Forms\Components\DatePicker::make('released_at')->required()->default(now()),
            Forms\Components\Textarea::make('body')
                ->required()
                ->rows(10)
                ->helperText('Plain text. Leave a blank line between paragraphs.')
                ->columnSpanFull(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('version')->badge()->color('info'),
                Tables\Columns\TextColumn::make('title')->searchable(),
                Tables\Columns\TextColumn::make('released_at')->date()->sortable(),
            ])
            ->defaultSort('released_at', 'desc')
            ->actions([Actions\EditAction::make(), Actions\DeleteAction::make()])
            ->bulkActions([Actions\BulkActionGroup::make([Actions\DeleteBulkAction::make()])]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListReleaseNotes::route('/'),
            'create' => Pages\CreateReleaseNote::route('/create'),
            'edit'   => Pages\EditReleaseNote::route('/{record}/edit'),
        ];
    }
}
