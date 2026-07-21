<?php

namespace App\Filament\Resources;

use App\Filament\Concerns\HasDomainPermission;

use App\Filament\Resources\BlogPostResource\Pages;
use App\Models\BlogPost;
use Filament\Forms;
use Filament\Schemas\Schema;
use Filament\Resources\Resource;
use Filament\Support\Enums\Width;
use Filament\Tables;
use Filament\Actions;
use Filament\Tables\Table;
use BackedEnum;
use UnitEnum;

class BlogPostResource extends Resource
{
    use HasDomainPermission;

    protected static string $requiredPermission = 'admin.content';

    protected static ?string $model = BlogPost::class;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-document-text';
    protected static string|\UnitEnum|null $navigationGroup = 'Content';
    protected static ?int $navigationSort = 1;
    protected static ?string $recordTitleAttribute = 'title';

    public static function form(Schema $schema): Schema
    {
        return $schema->schema([
            \Filament\Schemas\Components\Section::make('Content')->schema([
                Forms\Components\TextInput::make('title')->required()->maxLength(255)->live(onBlur: true)->columnSpanFull(),
                Forms\Components\TextInput::make('slug')->required()->maxLength(255)->unique(ignoreRecord: true)->columnSpanFull(),
                Forms\Components\Textarea::make('excerpt')->rows(2)->maxLength(500)->columnSpanFull(),
                Forms\Components\RichEditor::make('body')->required()->columnSpanFull(),
            ]),
            \Filament\Schemas\Components\Section::make('Meta')->columns(2)->schema([
                Forms\Components\TextInput::make('category')->maxLength(100),
                Forms\Components\Select::make('status')
                    ->options(['draft' => 'Draft', 'published' => 'Published', 'archived' => 'Archived'])
                    ->default('draft')
                    ->required(),
                Forms\Components\DateTimePicker::make('published_at')->native(false)->label('Publish at'),
                Forms\Components\TextInput::make('read_time_minutes')->numeric()->suffix('min read'),
                Forms\Components\TextInput::make('cover_image')->url()->maxLength(500)->label('Cover image URL')->columnSpanFull(),
                Forms\Components\Toggle::make('featured')->label('Featured on homepage'),
                Forms\Components\TextInput::make('seo_title')->maxLength(70)->label('SEO title'),
                Forms\Components\TextInput::make('seo_description')->maxLength(160)->label('SEO description'),
                Forms\Components\Select::make('author_id')
                    ->relationship('author', 'name')
                    ->searchable()
                    ->label('Author'),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('cover_image')->label('Cover')->width(60)->height(40),
                Tables\Columns\TextColumn::make('title')->searchable()->sortable()->limit(50),
                Tables\Columns\TextColumn::make('category')
                    ->badge()
                    ->color('info')
                    ->toggleable(),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'published' => 'success',
                        'archived'  => 'warning',
                        default     => 'gray',
                    }),
                Tables\Columns\IconColumn::make('featured')->boolean()->label('Featured'),
                Tables\Columns\TextColumn::make('view_count')->label('Views')->sortable(),
                Tables\Columns\TextColumn::make('published_at')->date('d M Y')->sortable()->label('Published'),
                Tables\Columns\TextColumn::make('author.name')->label('Author')->toggleable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options(['draft' => 'Draft', 'published' => 'Published', 'archived' => 'Archived']),
                Tables\Filters\TernaryFilter::make('featured'),
            ])
            ->actions([static::previewAction(), Actions\EditAction::make(), Actions\DeleteAction::make()])
            ->bulkActions([Actions\BulkActionGroup::make([Actions\DeleteBulkAction::make()])]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListBlogPosts::route('/'),
            'create' => Pages\CreateBlogPost::route('/create'),
            'edit'   => Pages\EditBlogPost::route('/{record}/edit'),
        ];
    }

    public static function previewAction(): Actions\Action
    {
        return Actions\Action::make('preview')
            ->label('Preview')
            ->icon('heroicon-o-eye')
            ->color('gray')
            ->modalHeading(fn (BlogPost $record) => "Preview: {$record->title}")
            ->modalWidth(Width::TwoExtraLarge)
            ->modalSubmitAction(false)
            ->modalCancelActionLabel('Close')
            ->modalContent(fn (BlogPost $record) => view('filament.blog-posts.preview', [
                'title' => $record->title,
                'excerpt' => $record->excerpt,
                'coverImage' => $record->cover_image,
                'category' => $record->category,
                'body' => $record->body,
            ]));
    }
}
