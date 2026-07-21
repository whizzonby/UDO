<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class FailedJob extends Model
{
    protected $table = 'failed_jobs';

    protected $fillable = ['uuid', 'connection', 'queue', 'payload', 'exception', 'failed_at'];

    public $timestamps = false;

    protected $casts = [
        'failed_at' => 'datetime',
    ];

    public function jobClass(): string
    {
        $payload = json_decode($this->payload, true);

        return $payload['displayName'] ?? $payload['job'] ?? 'Unknown job';
    }

    public function exceptionSummary(): string
    {
        return (string) Str::of($this->exception)->explode("\n")->first();
    }
}
