<?php

namespace App\Filament\Resources;

use App\Filament\Resources\VendorResource\Pages;
use App\Models\Vendor;
use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;

class VendorResource extends Resource
{
    protected static ?string $model = Vendor::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-building-storefront';
    protected static string|\UnitEnum|null $navigationGroup = 'Operations';
    protected static ?int $navigationSort = 2;
    protected static ?string $recordTitleAttribute = 'name';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Vendor details')->columns(2)->schema([
                Forms\Components\Select::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->searchable()->required()->label('Wedding'),
                Forms\Components\Select::make('category')
                    ->options(['venue' => 'Venue', 'catering' => 'Catering', 'photography' => 'Photography', 'florals' => 'Florals', 'music' => 'Music', 'hair_makeup' => 'Hair & Make-up', 'transport' => 'Transport', 'attire' => 'Attire', 'cake' => 'Cake', 'videography' => 'Videography', 'decor' => 'Decor', 'other' => 'Other'])
                    ->searchable()->required(),
                Forms\Components\TextInput::make('name')->required()->maxLength(255)->label('Business name'),
                Forms\Components\TextInput::make('contact_person')->maxLength(255),
                Forms\Components\TextInput::make('email')->email()->maxLength(255),
                Forms\Components\TextInput::make('phone')->tel()->maxLength(30),
                Forms\Components\TextInput::make('website')->url()->maxLength(255),
                Forms\Components\TextInput::make('instagram')->maxLength(100)->prefix('@'),
            ]),
            \Filament\Schemas\Components\Section::make('Financials & Status')->columns(2)->schema([
                Forms\Components\Select::make('booking_status')
                    ->options(['enquired' => 'Enquired', 'shortlisted' => 'Shortlisted', 'booked' => 'Booked', 'paid' => 'Paid', 'cancelled' => 'Cancelled'])
                    ->default('enquired')->required(),
                Forms\Components\Toggle::make('contract_signed')->label('Contract signed'),
                Forms\Components\TextInput::make('quoted_price')->numeric()->prefix('$'),
                Forms\Components\TextInput::make('deposit_paid')->numeric()->prefix('$')->default(0),
                Forms\Components\TextInput::make('balance_due')->numeric()->prefix('$')->default(0),
                Forms\Components\DatePicker::make('deposit_due_date')->native(false),
                Forms\Components\DatePicker::make('balance_due_date')->native(false),
                Forms\Components\Toggle::make('priority')->label('Priority vendor'),
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
                Tables\Columns\TextColumn::make('booking_status')->label('Status')->badge()
                    ->color(fn ($s) => match ($s) {
                        'booked' => 'info', 'paid' => 'success',
                        'cancelled' => 'danger', 'shortlisted' => 'warning', default => 'gray',
                    }),
                Tables\Columns\IconColumn::make('contract_signed')->boolean()->label('Contract'),
                Tables\Columns\TextColumn::make('quoted_price')->money('USD')->sortable()->label('Quote'),
                Tables\Columns\TextColumn::make('contact_person')->searchable()->toggleable(),
                Tables\Columns\TextColumn::make('email')->searchable()->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('booking_status')->label('Status')
                    ->options(['enquired' => 'Enquired', 'shortlisted' => 'Shortlisted', 'booked' => 'Booked', 'paid' => 'Paid', 'cancelled' => 'Cancelled']),
                Tables\Filters\SelectFilter::make('category')
                    ->options(['venue' => 'Venue', 'catering' => 'Catering', 'photography' => 'Photography', 'florals' => 'Florals', 'music' => 'Music']),
            ])
            ->actions([Actions\EditAction::make(), Actions\DeleteAction::make()])
            ->bulkActions([Actions\BulkActionGroup::make([Actions\DeleteBulkAction::make()])]);
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListVendors::route('/'),
            'create' => Pages\CreateVendor::route('/create'),
            'edit'   => Pages\EditVendor::route('/{record}/edit'),
        ];
    }
}
