<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\BudgetItemResource\Pages;
use App\Filament\Resources\BudgetItemResource\RelationManagers;
use App\Models\BudgetItem;
use Filament\Forms;
use Filament\Infolists;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;

class BudgetItemResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.operations';

    protected static ?string $model = BudgetItem::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-banknotes';
    protected static string|\UnitEnum|null $navigationGroup = 'Operations';
    protected static ?int $navigationSort = 12;
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

    public static function infolist(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Budget item')->columns(3)->schema([
                Infolists\Components\TextEntry::make('name'),
                Infolists\Components\TextEntry::make('wedding.couple_name_primary')->label('Wedding'),
                Infolists\Components\TextEntry::make('vendor.name')->label('Vendor')->default('-'),
                Infolists\Components\TextEntry::make('category')->badge(),
                Infolists\Components\TextEntry::make('payment_status')->label('Payment')->badge()
                    ->color(fn ($state) => match ($state) {
                        'paid' => 'success',
                        'partial' => 'warning',
                        default => 'gray',
                    }),
                Infolists\Components\TextEntry::make('due_date')->date()->placeholder('-'),
                Infolists\Components\TextEntry::make('estimated_amount')->money('usd')->label('Estimated'),
                Infolists\Components\TextEntry::make('actual_amount')->money('usd')->label('Actual'),
                Infolists\Components\TextEntry::make('paid_amount')->money('usd')->label('Paid'),
                Infolists\Components\TextEntry::make('balance_due')
                    ->label('Balance due')
                    ->money('usd')
                    ->getStateUsing(fn (BudgetItem $item) => max(0, (float) max($item->actual_amount, $item->estimated_amount) - (float) $item->paid_amount)),
                Infolists\Components\IconEntry::make('is_essential')->boolean()->label('Essential'),
            ]),
            \Filament\Schemas\Components\Section::make('Notes')->schema([
                Infolists\Components\TextEntry::make('notes')->default('-')->columnSpanFull(),
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
                Tables\Columns\TextColumn::make('balance_due')
                    ->label('Balance')
                    ->money('USD')
                    ->getStateUsing(fn (BudgetItem $item) => max(0, (float) max($item->actual_amount, $item->estimated_amount) - (float) $item->paid_amount))
                    ->sortable(),
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
            ->actions([Actions\ViewAction::make(), Actions\EditAction::make(), Actions\DeleteAction::make()])
            ->bulkActions([Actions\BulkActionGroup::make([Actions\DeleteBulkAction::make()])]);
    }

    public static function getRelations(): array
    {
        return [
            RelationManagers\PaymentSchedulesRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListBudgetItems::route('/'),
            'create' => Pages\CreateBudgetItem::route('/create'),
            'view'   => Pages\ViewBudgetItem::route('/{record}'),
            'edit'   => Pages\EditBudgetItem::route('/{record}/edit'),
        ];
    }

    public static function getNavigationLabel(): string { return 'Budget Items'; }
}
