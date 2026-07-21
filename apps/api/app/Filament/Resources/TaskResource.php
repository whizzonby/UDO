<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\TaskResource\Pages;
use App\Models\Task;
use App\Services\AdminBulkOpsService;
use Filament\Forms;
use Filament\Notifications\Notification;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Collection;

class TaskResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.operations';

    protected static ?string $model = Task::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-clipboard-document-check';
    protected static string|\UnitEnum|null $navigationGroup = 'Operations';
    protected static ?int $navigationSort = 8;
    protected static ?string $recordTitleAttribute = 'title';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Task')->columns(2)->schema([
                Forms\Components\Select::make('wedding_id')
                    ->relationship('wedding', 'couple_name_primary')
                    ->searchable()->required()->label('Wedding'),
                Forms\Components\Select::make('category')
                    ->options(['venue' => 'Venue', 'catering' => 'Catering', 'florals' => 'Florals', 'attire' => 'Attire', 'photography' => 'Photography', 'music' => 'Music', 'transport' => 'Transport', 'admin' => 'Admin', 'other' => 'Other'])
                    ->searchable(),
                Forms\Components\TextInput::make('title')->required()->maxLength(255)->columnSpanFull(),
                Forms\Components\Textarea::make('description')->rows(2)->columnSpanFull(),
                Forms\Components\Select::make('priority')
                    ->options(['low' => 'Low', 'medium' => 'Medium', 'high' => 'High', 'urgent' => 'Urgent'])
                    ->default('medium')->required(),
                Forms\Components\DatePicker::make('due_date')->native(false),
                Forms\Components\Toggle::make('completed')->label('Completed'),
                Forms\Components\Textarea::make('notes')->rows(2)->columnSpanFull(),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')->searchable()->sortable()->limit(50),
                Tables\Columns\TextColumn::make('wedding.couple_name_primary')->label('Wedding')->searchable(),
                Tables\Columns\TextColumn::make('category')->badge()->color('info'),
                Tables\Columns\TextColumn::make('priority')->badge()
                    ->color(fn ($s) => match ($s) {
                        'urgent' => 'danger', 'high' => 'warning',
                        'medium' => 'info', default => 'gray',
                    }),
                Tables\Columns\IconColumn::make('completed')->boolean()->label('Done'),
                Tables\Columns\TextColumn::make('due_date')->date()->sortable()->label('Due'),
                Tables\Columns\TextColumn::make('created_at')->since()->sortable()->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('due_date', 'asc')
            ->filters([
                Tables\Filters\SelectFilter::make('priority')
                    ->options(['low' => 'Low', 'medium' => 'Medium', 'high' => 'High', 'urgent' => 'Urgent']),
                Tables\Filters\TernaryFilter::make('completed')->label('Completion'),
                Tables\Filters\SelectFilter::make('category')
                    ->options(['venue' => 'Venue', 'catering' => 'Catering', 'florals' => 'Florals', 'attire' => 'Attire', 'photography' => 'Photography']),
            ])
            ->actions([Actions\EditAction::make(), Actions\DeleteAction::make()])
            ->bulkActions([
                Actions\BulkActionGroup::make([
                    static::bulkUpdateAction(),
                    Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListTasks::route('/'),
            'create' => Pages\CreateTask::route('/create'),
            'edit'   => Pages\EditTask::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::where('completed', false)->whereNotNull('due_date')->where('due_date', '<', now())->count() ?: null;
    }

    public static function getNavigationBadgeColor(): ?string { return 'warning'; }

    public static function bulkUpdateAction(): Actions\BulkAction
    {
        return Actions\BulkAction::make('bulkUpdate')
            ->label('Bulk update')
            ->icon('heroicon-o-pencil-square')
            ->color('warning')
            ->requiresConfirmation()
            ->modalDescription('Applies to every selected task. All selected tasks must belong to the same wedding.')
            ->schema([
                Forms\Components\Select::make('completed')
                    ->label('Completion')
                    ->options(['1' => 'Mark completed', '0' => 'Mark not completed'])
                    ->placeholder('No change'),
                Forms\Components\Select::make('priority')
                    ->options(['low' => 'Low', 'medium' => 'Medium', 'high' => 'High', 'urgent' => 'Urgent'])
                    ->placeholder('No change'),
            ])
            ->action(function (Collection $records, array $data, AdminBulkOpsService $bulkOps): void {
                $updates = array_filter([
                    'completed' => isset($data['completed']) ? (bool) $data['completed'] : null,
                    'priority' => filled($data['priority'] ?? null) ? $data['priority'] : null,
                ], fn ($value) => $value !== null);

                if (empty($updates)) {
                    Notification::make()->title('Nothing to update')->body('Choose at least one field to change.')->warning()->send();
                    return;
                }

                try {
                    $count = $bulkOps->applyUpdate('admin.tasks_bulk_updated', $records, $updates, auth()->user());
                } catch (\RuntimeException $e) {
                    Notification::make()->title('Bulk update blocked')->body($e->getMessage())->danger()->send();
                    return;
                }

                Notification::make()->title("Updated {$count} task(s)")->success()->send();
            });
    }
}
