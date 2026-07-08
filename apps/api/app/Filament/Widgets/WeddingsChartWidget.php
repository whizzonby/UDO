<?php

namespace App\Filament\Widgets;

use App\Models\Wedding;
use Filament\Widgets\ChartWidget;
use Illuminate\Support\Carbon;

class WeddingsChartWidget extends ChartWidget
{
    protected ?string $heading = 'New weddings — last 12 months';
    protected static ?int $sort = 2;
    protected int | string | array $columnSpan = 'full';

    protected function getData(): array
    {
        $months = collect(range(11, 0))->map(fn ($i) => now()->subMonths($i));

        $counts = $months->map(fn ($month) => Wedding::whereYear('created_at', $month->year)
            ->whereMonth('created_at', $month->month)
            ->count()
        );

        return [
            'datasets' => [
                [
                    'label' => 'New weddings',
                    'data' => $counts->values()->toArray(),
                    'fill' => true,
                    'backgroundColor' => 'rgba(40, 83, 1, 0.1)',
                    'borderColor' => '#285301',
                    'tension' => 0.4,
                ],
            ],
            'labels' => $months->map(fn ($m) => $m->format('M y'))->toArray(),
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }
}
