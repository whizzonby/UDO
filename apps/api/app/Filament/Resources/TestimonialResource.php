<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\TestimonialResource\Pages;
use App\Models\Testimonial;
use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;
use BackedEnum;
use UnitEnum;

class TestimonialResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.content';

    protected static ?string $model = Testimonial::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-chat-bubble-left-right';
    protected static string|\UnitEnum|null $navigationGroup = 'Content';
    protected static ?int $navigationSort = 2;
    protected static ?string $recordTitleAttribute = 'couple_names';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            Forms\Components\TextInput::make('couple_names')->required()->maxLength(255)->label('Couple names'),
            Forms\Components\TextInput::make('location')->maxLength(255),
            Forms\Components\DatePicker::make('wedding_date')->native(false),
            Forms\Components\Select::make('wedding_id')
                ->relationship('wedding', 'couple_name_primary')
                ->searchable()
                ->nullable()
                ->label('Linked wedding (optional)'),
            Forms\Components\Textarea::make('quote')->required()->rows(3)->columnSpanFull(),
            Forms\Components\TextInput::make('photo_url')->url()->maxLength(500)->label('Photo URL')->columnSpanFull(),
            Forms\Components\Select::make('rating')
                ->options(array_combine(range(1, 5), range(1, 5)))
                ->default(5),
            Forms\Components\Toggle::make('approved')->label('Approved / visible'),
            Forms\Components\Toggle::make('featured')->label('Featured'),
            Forms\Components\TextInput::make('sort_order')->numeric()->default(0),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('photo_url')->label('Photo')->circular(),
                Tables\Columns\TextColumn::make('couple_names')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('quote')->limit(60)->searchable(),
                Tables\Columns\TextColumn::make('rating')
                    ->formatStateUsing(fn ($state) => str_repeat('★', (int) $state)),
                Tables\Columns\IconColumn::make('approved')->boolean(),
                Tables\Columns\IconColumn::make('featured')->boolean(),
                Tables\Columns\TextColumn::make('wedding_date')->date('d M Y')->sortable(),
            ])
            ->defaultSort('sort_order', 'asc')
            ->filters([
                Tables\Filters\TernaryFilter::make('approved'),
                Tables\Filters\TernaryFilter::make('featured'),
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
            'index'  => Pages\ListTestimonials::route('/'),
            'create' => Pages\CreateTestimonial::route('/create'),
            'edit'   => Pages\EditTestimonial::route('/{record}/edit'),
        ];
    }
}
