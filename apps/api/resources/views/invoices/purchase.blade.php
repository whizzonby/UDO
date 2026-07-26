<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        body { font-family: DejaVu Sans, sans-serif; color: #1a1a1a; font-size: 13px; }
        h1 { color: #285301; font-size: 20px; margin-bottom: 4px; }
        .muted { color: #6b7280; }
        table { width: 100%; border-collapse: collapse; margin-top: 24px; }
        td { padding: 8px 0; border-bottom: 1px solid #e5e7eb; }
        .label { color: #6b7280; }
        .total { font-size: 16px; font-weight: bold; color: #285301; }
    </style>
</head>
<body>
    <h1>Udo</h1>
    <p class="muted">Invoice #{{ $invoiceNumber }}</p>

    <table>
        <tr>
            <td class="label">Billed to</td>
            <td>{{ $customerName }} ({{ $customerEmail }})</td>
        </tr>
        <tr>
            <td class="label">Date</td>
            <td>{{ $date }}</td>
        </tr>
        <tr>
            <td class="label">Payment method</td>
            <td>{{ $platformLabel }}</td>
        </tr>
        <tr>
            <td class="label">Description</td>
            <td>{{ $planLabel }} — one-time payment, full access</td>
        </tr>
        <tr>
            <td class="label total">Total paid</td>
            <td class="total">${{ $amount }}</td>
        </tr>
    </table>
</body>
</html>
