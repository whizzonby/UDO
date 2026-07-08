<?php

namespace App\Filament\Resources;

use App\Filament\Resources\BudgetItemResource\Pages;
use App\Models\BudgetItem;
use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;

class BudgetItemResource extends Resource
{
    protected static ?string $model = BudgetItem::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-banknotes';
    protected static string|\UnitEnum|null $navigationGroup = 'Operations';
    protected static ?int $navigationSort = 6;
    protected static ?string $recordTitleAttribute = 'name';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Budget item')->columns(2)->schema([
                Forms\Components\Select::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->searchable()->required()->label('Wedding'),
                Forms\Components\Select::make('category')
                    ->options(['venue' => 'Venue', 'catering' => 'Catering', 'photography' => 'Photography', 'florals' => 'Florals', 'music' => 'Music', 'attire' => 'Attire', 'transport' => 'Transport', 'decor' => 'Decor', 'cake' => 'Cake', 'invitations' => 'Invitations', 'other' => 'Other'])
                    ->searchable()->required(),
                Forms\Components\TextInput::make('name')->required()->maxLength(255),
                Forms\Components\Select::make('payment_status')
                    ->options(['pending' => 'Pending', 'partial' => 'Partial', 'paid' => 'Paid'])
                    ->default('pending')->required(),
                Forms\Components\TextInput::make('estimated_amount')->numeric()->prefix('$')->default(0)->label('Estimated'),
                Forms\Components\TextInput::make('actual_amount')->numeric()->prefix('$')->default(0)->label('Actual'),
                Forms\Components\TextInput::make('paid_amount')->numeric()->prefix('$')->default(0)->label('Paid'),
                Forms\Components\DatePicker::make('due_date')->native(false)->label('Due date'),
                Forms\Components\Toggle::make('is_essential')->label('Essential'),
                Forms\Components\Textarea::make('notes')->rows(2)->columnSpanFull(),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')->label('Wedding')->searchable(),
                Tables\Columns\TextColumn::make('category')->badge()->color('info'),
                Tables\Columns\TextColumn::make('payment_status')->label('Payment')->badge()
                    ->color(fn ($s) => match ($s) {
                        'paid' => 'success', 'partial' => 'warning', default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('estimated_amount')->money('USD')->label('Estimated')->sortable(),
                Tables\Columns\TextColumn::make('actual_amount')->money('USD')->label('Actual')->sortable(),
                Tables\Columns\TextColumn::make('paid_amount')->money('USD')->label('Paid')->sortable(),
                Tables\Columns\TextColumn::make('due_date')->date()->sortable()->label('Due'),
                Tables\Columns\IconColumn::make('is_essential')->boolean()->label('Essential'),
            ])
            ->defaultSort('due_date', 'asc')
            ->filters([
                Tables\Filters\SelectFilter::make('payment_status')->label('Payment')
                    ->options(['pending' => 'Pending', 'partial' => 'Partial', 'paid' => 'Paid']),
                Tables\Filters\SelectFilter::make('category')
                    ->options(['venue' => 'Venue', 'catering' => 'Catering', 'photography' => 'Photography', 'florals' => 'Florals']),
                Tables\Filters\TernaryFilter::make('is_essential')->label('Essential only'),
            ])
            ->actions([Actions\EditAction::make(), Actions\DeleteAction::make()])
            ->bulkActions([Actions\BulkActionGroup::make([Actions\DeleteBulkAction::make()])]);
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListBudgetItems::route('/'),
            'create' => Pages\CreateBudgetItem::route('/create'),
            'edit'   => Pages\EditBudgetItem::route('/{record}/edit'),
        ];
    }

    public static function getNavigationLabel(): string { return 'Budget Items'; }
}
