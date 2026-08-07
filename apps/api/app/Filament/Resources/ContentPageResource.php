<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\ContentPageResource\Pages;
use App\Models\ContentPage;
use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;
use BackedEnum;
use UnitEnum;

class ContentPageResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.content';

    protected static ?string $model = ContentPage::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-document-text';
    protected static string|\UnitEnum|null $navigationGroup = 'Content';
    protected static ?int $navigationSort = 5;
    protected static ?string $navigationLabel = 'Content Pages';
    protected static ?string $recordTitleAttribute = 'title';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            Forms\Components\TextInput::make('title')->required()->maxLength(150)->columnSpanFull(),
            Forms\Components\TextInput::make('slug')
                ->required()
                ->unique(ignoreRecord: true)
                ->helperText('Used by the app to look up this page, e.g. privacy-policy, terms-of-service, company-information. Changing it will break anything that references the old slug.')
                ->columnSpanFull(),
            Forms\Components\Textarea::make('body')
                ->required()
                ->rows(20)
                ->helperText('Plain text. Leave a blank line between paragraphs.')
                ->columnSpanFull(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')->searchable(),
                Tables\Columns\TextColumn::make('slug')->badge()->color('gray'),
                Tables\Columns\TextColumn::make('updated_at')->dateTime()->sortable(),
            ])
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
            'index'  => Pages\ListContentPages::route('/'),
            'create' => Pages\CreateContentPage::route('/create'),
            'edit'   => Pages\EditContentPage::route('/{record}/edit'),
        ];
    }
}
