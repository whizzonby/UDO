<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\EmailTemplateResource\Pages;
use App\Mail\TemplatedMail;
use App\Models\EmailTemplate;
use Filament\Actions;
use Filament\Forms;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Enums\Width;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Support\Facades\Mail;

class EmailTemplateResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.content';

    protected static ?string $model = EmailTemplate::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-envelope';
    protected static string|\UnitEnum|null $navigationGroup = 'Content';
    protected static ?int $navigationSort = 4;
    protected static ?string $navigationLabel = 'Email Templates';
    protected static ?string $recordTitleAttribute = 'name';

    /** Sample values so "Send test email" and the live preview render something readable. */
    public static function sampleData(EmailTemplate $record): array
    {
        $frontendUrl = rtrim(config('app.frontend_url', 'http://localhost:3000'), '/');

        $samples = [
            'first_name' => 'Alex',
            'last_name'  => 'Morgan',
            'reset_url'  => "{$frontendUrl}/reset-password?token=sample-token&email=alex%40example.com",
            'verify_url' => url('/api/auth/email/verify/0/sample-hash?expires=9999999999&signature=sample'),
        ];

        return collect($record->available_variables ?? [])
            ->mapWithKeys(fn (string $var) => [$var => $samples[$var] ?? "{{$var}}"])
            ->toArray();
    }

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            Forms\Components\TextInput::make('key')
                ->required()
                ->unique(ignoreRecord: true)
                ->helperText('Used in code to send this email, e.g. welcome, password_reset. Changing it will break anything that references the old key.')
                ->columnSpanFull(),
            Forms\Components\TextInput::make('name')
                ->required()
                ->maxLength(150)
                ->columnSpanFull(),
            Forms\Components\TextInput::make('subject')
                ->required()
                ->maxLength(255)
                ->columnSpanFull(),
            Forms\Components\RichEditor::make('body')
                ->required()
                ->columnSpanFull(),
            Forms\Components\TagsInput::make('available_variables')
                ->label('Available variables')
                ->helperText('Placeholders that can be used as {{variable}} in the subject or body above.')
                ->columnSpanFull(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')->searchable(),
                Tables\Columns\TextColumn::make('key')->badge()->color('gray'),
                Tables\Columns\TextColumn::make('subject')->limit(50)->searchable(),
                Tables\Columns\TextColumn::make('updated_at')->dateTime()->sortable(),
            ])
            ->actions([static::previewAction(), static::sendTestEmailAction(), Actions\EditAction::make(), Actions\DeleteAction::make()])
            ->bulkActions([Actions\BulkActionGroup::make([Actions\DeleteBulkAction::make()])]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListEmailTemplates::route('/'),
            'create' => Pages\CreateEmailTemplate::route('/create'),
            'edit'   => Pages\EditEmailTemplate::route('/{record}/edit'),
        ];
    }

    public static function previewAction(): Actions\Action
    {
        return Actions\Action::make('preview')
            ->label('Preview')
            ->icon('heroicon-o-eye')
            ->color('gray')
            ->modalHeading(fn (EmailTemplate $record) => "Preview: {$record->name}")
            ->modalWidth(Width::TwoExtraLarge)
            ->modalSubmitAction(false)
            ->modalCancelActionLabel('Close')
            ->modalContent(function (EmailTemplate $record) {
                $rendered = EmailTemplate::render($record->key, self::sampleData($record));

                return view('filament.email-templates.preview', [
                    'subject' => $rendered['subject'],
                    'html' => view('emails.layout', ['bodyHtml' => $rendered['body']])->render(),
                ]);
            });
    }

    public static function sendTestEmailAction(): Actions\Action
    {
        return Actions\Action::make('sendTest')
            ->label('Send test email')
            ->icon('heroicon-o-paper-airplane')
            ->schema([
                Forms\Components\TextInput::make('email')
                    ->email()
                    ->required()
                    ->default(fn () => auth()->user()?->email),
            ])
            ->action(function (array $data, EmailTemplate $record): void {
                Mail::to($data['email'])->send(new TemplatedMail($record->key, self::sampleData($record)));

                Notification::make()
                    ->title("Test email sent to {$data['email']}")
                    ->success()
                    ->send();
            });
    }
}
